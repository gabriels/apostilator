#!/bin/perl
# apostilator
# Copyright (c) 2007 Luiz C. B. Mostaço Guidolin <lcguid@apostilator.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  
# USA
#

sub usage() 
{
    print STDERR "Usage: apostilator commands [options]\n\n" ;
    print STDERR "Commands are:\n" ;
    print STDERR "    init        :    initializes a new project;\n" ;
    print STDERR "    clean       :    remove unnecessary files;\n" ;
    print STDERR "    backup      :    make a backup of your work;\n" ;
    print STDERR "    final       :    generates the final version of " ;
    print STDERR "your work (latex 3 times);\n" ;
    print STDERR "    view        :    enable/disable the opening of " ;
    print STDERR "the pdf viewer;\n" ;
    print STDERR "    author      :    double quoted list of names of " ;
    print STDERR "the authors of the work;\n" ;
    print STDERR "    title       :    double quoted title of the work;\n" ;
    print STDERR "    footer      :    double quoted content of the footer of " ;
    print STDERR "the titlepage;\n" ;
    print STDERR "    help        :    show this help." ;
    print STDERR "To initialize a new project:\n" ;
    print STDERR "Usage example:\n\n" ;
    print STDERR "apostilator init <project_name> [<project_type>]\n\n" ;
    print STDERR "Available project types:\n\t" ;
    print STDERR "report      :\tBook-like project (default)\n\n" ;
    print STDERR "Bugs: <bugs\@apostilator.org>.\n";
}
###

sub set_work_param()
{
  my ( $param , $value ) = @_ ;
  check_workdir( $ENV{PWD} ) ;

  use Encode ;
  my $macros = "$ENV{PWD}/.macros.tex" ;
  my $tmp_macros = "/tmp/$ENV{USER}-macros.tex" ;
  my $ctrl ;

  open MACROS , $macros or die "[$macros]: $!" ;
  open TMP_MACROS , ">$tmp_macros" or die "[$tmp_macros]: $!" ;

    while( <MACROS> )
    {
        my $line = $_ ;
        my $enc_name = Encode::is_utf8($line)? 'utf8' : 'false' ;
                    
        if( $enc_name eq 'false' )
          { $line = encode( "utf8" , decode( "iso-8859-1" , $line ) ) ; }

        if( $line =~ /\\renewcommand\{\\$param\}\{(.+)\}/ )
        {  
           $line =~ s/\\renewcommand\{\\$param\}\{(.+)\}/\\renewcommand\{\\$param\}\{$value\}/ ;
           $ctrl = 1 ;
        }
        print TMP_MACROS $line ; 
    }

    if( ! defined $ctrl )
    { print TMP_MACROS encode( "utf8" ,"\\renewcommand\{\\$param\}\{$value\}\n" ) ; }

  close TMP_MACROS ;
  close MACROS ;
  system( "mv $tmp_macros $macros" );
}
###

sub clean()
{
  check_workdir( $ENV{PWD} ) ;

  print "\nRemoving temporary files!\n\n" ;

  my $pwd = "$ENV{PWD}/.tex" ;

  opendir TEX_DIR , $pwd or die "[$pwd]: Can not open directory." ;
    foreach( readdir TEX_DIR ) 
    {
       my $file = "$pwd/$_" ;
       next if (-d "$file") ;
       next if /^(apostilator\_titlepage|base)\.tex$/ ;
       unlink("$file") if( -l "$file" ) ;
       unlink("$file") ;
    }
  closedir TEX_DIR ;

  $pwd = "$ENV{PWD}/archives" ;

  opendir ARCHIVES , $pwd or die "[$pwd]: Can not open directory." ;
    foreach( readdir ARCHIVES )
    {
      my $file = "$pwd/$_" ;
      next if( -d $file ) ;
      unlink( "$file" ) if $file =~ /~$/ ;
    }
  closedir ARCHIVES ;

  $pwd = "$ENV{PWD}" ;

  opendir DIR , $pwd or die "[$pwd]: Can not open directory." ;
    foreach( readdir DIR )
    {
      my $file = $_ ;
      next if( -d $file ) ;
      unlink( "$file" ) if $file =~ /~$/ ;
      unlink( "$file" ) if $file =~ /\.log$/ ;
    }
  close DIR ;
}
###

sub forced_stop()
{
  my $count = 0 ;
  while( system("killall -9 pdflatex >/dev/null 2>&1" ) == 0 )
  {
    if( $count > 3)
    { print"\nPdflatex still running.\n" ;
      exit ;
    }
    sleep(1);
    $count++;
  }
  print "\nExit successfully\n";
  exit;
}
###



sub check_workdir()
{
  my ( $workdir ) = @_ ;
  my @files = qw( capitulos.txt apendices.txt .tex/base.tex) ;
  my @directories = qw( archives .tex ) ;

  foreach( @directories )
  { if( ! -d "$workdir/$_" ) 
    { print "\nDirectory not found: [$_]!\n" ;
      print "Are you in the right directory?\n" ;
      exit ;
    }
  }

  foreach( @files )
  { if( ! -f "$workdir/$_" )
    { print "\nFile not found: [$_]!\n" ;
      print "Are you in the right directory?\n" ; 
      exit ;
    }
  }
}
###


# This function reads all the XML tags from file(s) and initializes the
# specified hash. The default tags file is located at 
# /usr/share/apostilator/tags and, the user-defined tags are located at 
# $workdir/.tags.xml.
sub readTags() {
  my ( $tagsFile , $PHtags ) = @_ ;

  if( ! -f $tagsFile ) {
    print "Could not find the TAG file: [$tagsFile]\n" ;
    exit ;
  }
  else {
    open TAG , "<$tagsFile" or die "[$tagsFile]: $!" ;
    
    foreach( <TAG> ) {
        next if $_ =~ /^#/ ;
        next if $_ !~ /^</ ;
        chomp ;
        my ( $tag , $value ) = split( /:/ , $_ ) ;
        $value =~ s/"//g ;
        $PHtags->{$tag} = $value if defined $tag ;
    }
    close TAG ;
  }
}
###

# It reads and parses configuration files
sub read_confs
{
	my ( $conf_file , $PHconfs ) = @_ ;

	open CONFS , $conf_file or die "[$conf_file]: $!" ;

	while( <CONFS> )
	{
		next if $_ =~ /^\#/ or /^\n/ ;
		my ( $key , $value ) =  split( /=/ , $_ ) ;
		chomp( $key , $value ) ;
		$PHconfs->{$key} = $value ;
	}

	close CONFS ;
}
###

sub start_new_project()
{
    my ( $prj_name , $prj_type ) = @_ ;

    if( ! defined $prj_name ) 
    { print "\nWhat is the project name?\n\n" ; &usage() ; exit ; }

    my $prj_dir = "$ENV{PWD}/$prj_name" ;
    my $template_dir = "/usr/share/apostilator/templates/" ;

    mkdir( $prj_dir ) if ! -d $prj_dir or die "[$prj_dir]: Already Exists! stopping" ;
  
    $prj_type = "report" if ! defined $prj_type ;
    $template_dir .= $prj_type ; 

    if( ! -d $template_dir )
      { die "\nTemplate [$prj_type] not found at: $template_dir\n"; }

    system( "cp -r $template_dir/* $prj_dir/" ) ;
    system( "mv $prj_dir/tex $prj_dir/.tex" ) ;
    system( "mv $prj_dir/tags.xml $prj_dir/.tags.xml" ) ;
    system( "mv $prj_dir/macros.tex $prj_dir/.macros.tex" ) ;
    system( "ln -s $prj_dir/archives/imgs $prj_dir/.tex/imgs" ) ;
    system( "ln -s $prj_dir/.macros.tex $prj_dir/.tex/apostilator_user_defined_macros.tex" ) ;
}
###

sub verify_depends()
{
    my @depends = ( "pdflatex" , "bibtex" , "rm" , "cp" , "mv" ,
                    "sed" , "tar" , "gzip" , "killall" , "pgrep" ,
                    "unlink" , "tail" ) ;
                    
    foreach( @depends )
    {
        if( system( "which $_ 2>&1 > /dev/null" ) != 0 )
        {
            print "Binary $_ not found in \$PATH.\n" ;
            print "Please install packages: tetex, tetex-extra, latex-ucs.\n" ;
            exit;
        }
    }
}
###



1;
