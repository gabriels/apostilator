#!/usr/bin/perl -w
#
# apostilator.pl v0.2.8-20111225
# Copyright (c) 2007-2011 Reinaldo de Carvalho <reinaldoc@gmail.com>
# Copyright (c) 2005-2006 Luiz C. B. Mostaço Guidolin <lcguid@gmail.com>
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

use strict ;

my $version = "v0.2.8-20111225";
my $pdf_view = "xpdf";
my $pdf_exec = "on";
my $pdf_make = "on";
my $lst_make = "off";
my $summary  = "off";
my $summaryt = "Resumo";
my $bkrotate = 3;
my %tags = (	"<capitulo>" => "\\newpage \\chapter{",
                "</capitulo>" => "}\\setcounter{SteP}{1}",
                "<subsecao>" => "\\section{",
                "</subsecao>" => "}\\setcounter{SteP}{1}",
                "<subsubsecao>" => "\\subsection{",
                "</subsubsecao>" => "}\\setcounter{SteP}{1}",
                "<subsubsubsecao>" => "\\subsubsection{",
                "</subsubsubsecao>" => "}\\setcounter{SteP}{1}",
                "<comando>" => "\\begin{BoxVerbatim}",
                "</comando>" =>	"\\end{BoxVerbatim}",
                "<comandoNumerado>" => "\\begin{VerbatimNumerado}",
                "</comandoNumerado>" => "\\end{VerbatimNumerado}",
                "<b>" => "{\\bf ",
                "</b>" => "}",
                "<i>" => "{\\it ",
                "</i>" => "}",
                "<lista>" => "\\begin{itemize}",
                "</lista>" => "\\end{itemize}",
                "<enumerar>" => "\\begin{enumerate}",
                "</enumerar>" => "\\end{enumerate}",
                "<item>" => "\\item{\\bf ",
                "</item>" => "}",
                "<item/>" => "\\item{\\bf }",
                "<item />" => "\\item{\\bf }",
                "<nome>" => "\\label{",
                "</nome>" => "}",
                "<ref>" => "~\\ref{",
                "</ref>" => "}",
                "<citar>" => "~\\cite{",
                "</citar>" => "}",
                "<tabela>" => "\\begin{table}[H]\n  \\begin{center}\n  \\begin{tabular}",
                "</tabela>" => "  \\end{center}\n\\end{table}",
                "<th>" => "{\\bf ",
                "</th>" => "}",
                "<col>" => "\t&\t",
                "<col/>" => "\t&\t",
                "<col />" => "\t&\t",
                "<lh>" => "\\hline",
                "</lh>" => " \\\\ \\hline \\hline",
                "<tr>" => "",
                "</tr>" => " \\\\ \\hline",
                "<math>" => "\$",
                "</math>" => "\$",
                "<figura>" => "\\begin{figure}[H]\\begin{center}",
                "</figura>" => "\\end{center}\\end{figure}",
                "<tamanho>" => "\\includegraphics[width=",
                "</tamanho>" => "\\columnwidth]",
                "<arquivo>" => "{",
                "</arquivo>" => "}",
                "<tamanhob>" => "\\setlength\\fboxsep{0pt}\\setlength\\fboxrule{2.0pt}\\fbox{\\includegraphics[width=",
                "</tamanhob>" => "\\columnwidth]",
                "<arquivob>" => "{",
                "</arquivob>" => "}}",
                "<legenda>" => "\\caption{",
                "</legenda>" => "}",
                "<equacao>" => "\\begin{equation}",
                "</equacao>" => "\\end{equation}",
                "<centro>" => "\\begin{center}",
                "</centro>" => "\\end{center}",
                "<step>" => "\\vskip 0.30cm \\noindent{\\bf \\arabic{SteP}. ",
                "</step>" => "}\\addtocounter{SteP}{1} \\vskip 0.15cm",
                "<quebraPagina>" => "\\newpage",
                "<quebraPagina/>" => "\\newpage",
                "<quebraPagina />" => "\\newpage",
                "<linha>" => "\\\\ \\makebox[1\\textwidth]{\\hrulefill}",
                "<linha/>" => "\\\\ \\makebox[1\\textwidth]{\\hrulefill}",
                "<linha />" => "\\\\ \\makebox[1\\textwidth]{\\hrulefill}",
                "<lpi>" => "\\lpi{}",
                "<lpi/>" => "\\lpi{}",
                "<lpi />" => "\\lpi{}",
                "</lpi>" => "",
                "<bslash/>" => "\\textbackslash ",
                "<br/>" => "\\vskip ",
                "<rh>" => "\\rh{}",
                "</rh>" => "",
                "<resumo>" => "",
                "</resumo>" => "" ) ;

my %strangeChars = ("\#"  => "\\#" , '[$]' => "\\\$", "\%" => "\\\%"  ,
                    "\&"  => "\\&" , "\_"  => "\\\_" ,
                    "{"   => "\\{" , "}"   => "\\}" ) ;

my %reservedChars = ( ";lt;" => "<" , ';gt;' => ">" , ';amp;' => "\&" ) ;

my %mathChars = ( ';bs;' => '$\backslash$' , '[|]' => "\$\\mid\$" ) ;            

my $workdir = "";
my $bibliografy = "off";

&main();

sub main() {
  &verify_depends();
  my $all_stages = "on";
  if( defined @ARGV ) {
      my @ARGS = @ARGV;
      while ($#ARGS >= 0) {
          $_ = $ARGS[0];
          if( /^(-h|--help)$/ ) {
              &usage();
              exit;
          }
          if( /^(-v|--version)$/ ) {
              &version;
              exit;
          }
          if( /^(-w=|--workdir=)(.+)$/ ) {
              $workdir = &check_workdir("$2");
          }
          shift @ARGS;
      }
      if (!"$workdir") {
          $workdir = &check_workdir("$ENV{PWD}");
      }
      while ($#ARGV >= 0) {
          $_ = $ARGV[0];
          if( /^(-l|--make-lst)$/ ) {
              $lst_make = "on";
          }
          if( /^(-n|--no-open-pdf)$/ ) {
              $pdf_exec = "off";
          }
          if( /^(-y|--with-summary)$/ ) {
              $summary = "on";
          }
          if( /^(-a=|--set-author=)(.+)$/ ) {
              &set_author("$2");
          }
          if( /^(-t=|--set-title=)(.+)$/ ) {
              &set_title("$2");
          }
          if( /^(-u=|--set-customer=)(.+)$/ ) {
              &set_customer("$2");
          }
          if( /^(-c|--clean)$/ ) {
              print "Clean temporary files.\n";
              &clean();
              exit;
          }
          if( /^(-b|--backup)$/ ) {
              print "Copying necessary files.\n";
              &backup();
              exit;
          }
          if( /^(-s|--skip-pdf)$/ ) {
              $pdf_make = "off";
          }
          if( /^(-p|--preview)$/ ) {
              $all_stages = "off";
          }
          shift(@ARGV);
      }
  }
  if (!"$workdir") {
      $workdir = &check_workdir("$ENV{PWD}");
  }
  unless (-e "$workdir/.tex/base.aux") { $all_stages = "on" }
  if ("$lst_make" eq 'on') {
      &make_lst();
  }
  if ("$pdf_make" eq 'on') {
      print "Apostilator running on $workdir.\n";
      &start( $all_stages );
  }
  exit;
}

sub usage() {
    print "Usage: apostilator.pl [ --workdir= ] [ OPTION ]... [ ACTION ] \n";
    print "Options available:\n";
    print "    -a=,    --set-author=          Set project Author. Use slash before spaces.\n";
    print "    -t=,    --set-title=           Set project title.  Use slash before spaces.\n";
    print "    -u=,    --set-customer=        Set project customer.  Use slash before spaces.\n";
    print "    -w=,    --workdir=             Set workdir instead PWD.\n";
    print "    -l ,    --make-lst             Make chapters/appendix list sorted by name.\n";
    print "    -n ,    --no-open-pdf          Do not exec PDF viewer.\n";
    print "    -y ,    --with-summary         Add chapter with summary.\n\n";
    print "Actions available:\n";
    print "    -b ,    --backup               Build a tar.gz with necessary files.\n";
    print "    -c ,    --clean                Clean temporary files.\n";
    print "    -p ,    --preview              Dont make all LaTeX stages.\n";
    print "    -s ,    --skip-pdf             Do everything, but don't build PDF.\n\n";
    print "Others:\n";
    print "    -h ,    --help                 Show this help.\n";
    print "    -v ,    --version              Print program version.\n\n";
    print "Bugs: <reinaldoc\@gmail.com>.\n";
}

sub version() {
    print "Apostilator.pl $version.\n\n";
    print "This is free software.\n";
    print "GNU General Public License <http://www.gnu.org/licenses/gpl.html>.\n";
    print "There is NO WARRANTY, to the extent permitted by law.\n";
    print "Written by Reinaldo Carvalho and Luiz C. B. Mostaço Guidolin.\n";
}

sub verify_depends() {
    my @depends = ("pdflatex","bibtex","rm","cp","mv","sed","tar","gzip","killall","pgrep","unlink","tail");
    foreach (@depends) {
      if (system("which $_ 2>&1 > /dev/null") != 0) {
        print "Binary $_ not found in \$PATH.\n";
        print "Please install packages: texlive, texlive-latex-recommended, texlive-latex-extra, texlive-fonts-extra.\n";
        exit;
      }
    }
}

sub clean() {
    opendir TEX, "$workdir/.tex" or die "Can not open directory $workdir/.tex.";
    foreach( readdir TEX ) {
      my $file = "$workdir/.tex/$_";
      if (-l "$file") {	unlink("$file") }
      next if (-d "$file");
      next if /^(titlepage\.tex|titlepage\.png|titlepage\.jpg|base\.tex|babelbib\.sty|portuguese\.bdf)$/; 
      unlink("$file");
    }
    unlink("$workdir/.apostilator.log");
    closedir TEX;
}

sub project_name() {
    if ( "$workdir" =~ /.*\/(.+$)/ ) { return "$1" }
}

sub backup() {
    &clean();
    my $project = &project_name();
    if (-e "$workdir/.$project") {
        system("rm -rf $workdir/.$project");
    }
    mkdir("$workdir/.$project");
    system("cp -a $workdir/* $workdir/.tex $workdir/.$project/ >> $workdir/.apostilator.log 2>&1");

    use POSIX qw(strftime);
    my $now = strftime "%Y%m%d", localtime;
    my $file;
    if ( "$workdir" =~ /.*\/(.+$)/ ) {
        $file = "$1-$now.tar.gz";
    } else {
        print "Backup failed.";
        return;
    }
    my $j;
    for (my $i=$bkrotate-1;$i>=0;$i--) {
        if ($i == 0) {
            $j = "";
        } else {
            $j = $i-1;
            $j = ".$j";
        }
        if (-e "$workdir/../$file$j") { system("mv $workdir/../$file$j $workdir/../$file.$i") }
    }
    system("mv $workdir/.$project $workdir/$project");
    system("tar czf $workdir/../$file ./$project -C $workdir/");
    system("rm -rf $workdir/$project");
    print "Backup $file created.\n";
}

sub set_author() {
  my ( $author ) = @_;
  system("sed -i \'s/\{\\\\small.*\}/\{\\\\small $author\}/\' $workdir/.tex/titlepage.tex");
}

sub set_title() {
  my ( $title ) = @_;
  system("sed -i \'s/.*\\\\sf\$//\'  $workdir/.tex/titlepage.tex");
  system("sed -i \'s/.*\\\\vskip 0.15cm/\{\\\\huge \\\\sf \{$title\}\\\\vskip 0.15cm/\' $workdir/.tex/titlepage.tex");
}

sub set_customer() {
  my ( $customer ) = @_;
  system("sed -i \'s/  \{\\\\huge.*\}/  \{\\\\huge $customer\}/\' $workdir/.tex/titlepage.tex");
}

sub make_lst() {
  print "$workdir\n";
  opendir(DIR, $workdir);
  my $file;
  while (defined($file = readdir(DIR))) {
    if ( $file =~ /^[0-8].*\.xml$/ ) {
      print "$file\n";
    }
  } 
}

sub start() {

    $SIG{TERM} = \&stop;
    $SIG{INT} = \&stop;

    my ( $all_stages ) = @_;
    if ("$all_stages" eq 'on') {
        &clean;
    }

    open LOG, ">$workdir/.apostilator.log";
    my $now = localtime time;
    print LOG "\n### Apostilator is running: $now\n\n";

    $now = localtime time;
    print LOG "\n### Apostilator::create_symlinks(): $now\n\n";
    &create_symlinks();

    $now = localtime time;
    print LOG "\n### Apostilator::convert_apostila(): $now\n\n";
    &convert_apostila();

    $now = localtime time;
    print LOG "\n### Apostilator::convert_latex2pdf(): $now\n\n";
    &convert_latex2pdf( '1' );

    $now = localtime time;
    print LOG "\n### Apostilator::create_bibliography(): $now\n\n";
    &create_bibliography();

    if ("$all_stages" eq 'on') {
        &convert_latex2pdf( '2' );
        &convert_latex2pdf( '3' );
    }
    if (-e "$workdir/.tex/base.pdf") {
        use File::Copy;
        my $project = &project_name();
        move("$workdir/.tex/base.pdf", "$workdir/$project.pdf");
    }
    if ("$pdf_exec" eq 'on') {
        &pdf();
    }
    close LOG;
}

sub pdf() {
  my @programs = ("$pdf_view","xpdf","evince","kpdf","acroread");
  foreach( @programs ) {
        if (system("which $_ 2>&1 >/dev/null") == 0) {
            my $project = &project_name();
            system("$_ \'$workdir/$project.pdf\' 2>/dev/null &");
            return;
        }
  }
}

sub stop() {
  my $i = 0;
  while (system("killall -9 pdflatex >/dev/null 2>&1") == 0) {
    if ("$i" > 3) {
      print"\nPdflatex still running.\n";
      exit;
    }
    sleep(1);
    $i++;
  }
  print "\nExit successfully\n";
  exit;
}

sub check_workdir() {
    my $workdir = "@_";
    if (-r "$workdir/.tex/base.tex") {
        chdir("$workdir") or die "Can not change directory to: $workdir.\n";
        $workdir = readlink "/proc/self/cwd";
    } else {
        print "Please especify a valid directory: $workdir.\n";
        exit ;
    }
    return $workdir;
}

sub create_symlinks() {
    chdir("$workdir") or die "Can not change directory to: $workdir.";
    
    mkdir("$workdir/.tex", 0755);
    mkdir("$workdir/imgs", 0755);
    system("rm -rf $workdir/.tex/imgs 2>/dev/null");
    symlink("../imgs",".tex/imgs");
    
    unless (-e "$workdir/Bibliography.bib") {
      open BIBLIOGRAFY, ">$workdir/Bibliography.bib" or die "Error open file: Bibliography.bib.\n";
      print BIBLIOGRAFY "\n";
      close BIBLIOGRAFY;
    }
    unlink("$workdir/.tex/Bibliography.bib");
    symlink("../Bibliography.bib" ,".tex/Bibliography.bib");
}

sub create_bibliography() {
    if ($bibliografy eq "off") {
        print "Skipping Bibliografy, it was not cited on chapters.\n";
        return;
    }
    unless (-e "$workdir/.tex/base.aux") {
      print "Please configure base.aux inside tex directory.\n";
      print "It may have occurred due to Apostilator-XML syntax error.\n";
      exit;
    }
    open BIBLIOGRAFY, "$workdir/Bibliography.bib";
    my $i = 0;
    while( <BIBLIOGRAFY> ) {
      $i++;
      next if /^\n/ ;
      next if /^\@Article{\w+,\n/ ;
      next if /^\@Misc{\w+,\n/ ;
      next if /^\s*title\s+=\s+\".*\"\s*,\n/ ;
      next if /^\s*author\s+=\s+\".*\"\s*,\n/ ;
      next if /^\s*journal\s+=\s+\".*\"\s*,\n/ ;
      next if /^\s*note\s+=\s+\".*\"\s*,\n/ ;
      next if /^\s*year\s+=\s+\d{4}\s*\n/ ;
      next if /^\s*\}\s*\n/;
      if ($_ =~ /^\s*(\#|\;|\/)/) {
        print "Bibliografy file doesn't support comments. (line $i)\n";
        exit;
      }
      print "Syntax Error on the Bibliografy file. (line $i)\n";
      exit;
    }
    close BIBLIOGRAFY;
    print "Converting to Tex: $workdir/Bibliography.bib.\n";
    chdir "$workdir/.tex";
    system("bibtex base >> $workdir/.apostilator.log 2>&1");
}

sub convert_apostila() {

    my $resFileXML = "$workdir/Abridgment.xml" ;

    open resFILEXML , ">$resFileXML" or die "Can't open file Abridgment.xml:  $!" ;
    print resFILEXML "<capitulo>$summaryt</capitulo>\n\n" ;
    close resFILEXML ;

    &convert_filelist("$workdir/Chapters.lst","$workdir/.tex/Chapters.tex","$resFileXML");
    &convert_filelist("$workdir/Appendix.lst","$workdir/.tex/Appendix.tex","$resFileXML");
    
    if ($summary ne "off") {
        &convert_file2latex( $resFileXML, "$workdir/.tex/Abridgment.tex", "/dev/null");
        open TEX, ">>$workdir/.tex/Chapters.tex" or die "Can't open file Chapters.tex: $!";
        print TEX "\\input{Abridgment}\n";
        close TEX;
    }

    unlink("$resFileXML");
}

sub convert_filelist() {
    my ( $inFileList , $outFileList , $resFileXML) = @_ ;
    open XML, "$inFileList" or die "Can't open file: $inFileList.\n";
    open TEX, ">$outFileList" or die "Can't open file: $outFileList.\n";
    my $i = 0;
    while ( <XML> ) {
        next if (/^(\#|\/|\;)/);
        if (/\.\w+$/) {
            print "Please, use files without extensions. Ignoring file ${_}";
            next;
        }
        my $line = $_;
        $line =~ s/\n//;
        my $inFile = "$workdir/$line.xml";
        my $outFile = "$workdir/.tex/$line.tex";
        &convert_file2latex( $inFile , $outFile , $resFileXML);
        print TEX "\\input{$line}\n";
        $i++;
    }
    close XML;
    close TEX;
    print "Skipping $inFileList, no chapters.\n" if $i == 0;
}

sub convert_file2latex() {
    my ( $inFile , $outFile, $resFile ) = @_ ;
    my $comandoCTRL = 0 ;
    my $tabelaCTRL = 0 ;
    my $equacaoCTRL = 0 ;
    my $resumeCTRL = 0 ;
    my $i = 0;

    open inFILE , $inFile or die "Can not open file: $inFile.\n";
    open resFILE , ">>$resFile" or die "Can not open file: $resFile.\n";
    print "Converting to Latex: $inFile.\n" ;
    open outFILE , ">$outFile" or die "Can not open file: $outFile.\n";
    select outFILE ;

    foreach my $line ( <inFILE> ) {
        $i++;
        my @pilhaTags ;
        my $pilhaCounter = 0 ;
        
        # Tratamento <citar>
        if( $line =~ /<citar>/ ) {
          $bibliografy = "on";
        }

        # Tratamento do Pulo do Gato. <resumo></resumo>
        if( $line =~ /<resumo>/ ) {
            if ($resumeCTRL == 1) {
              print STDOUT "Invalid XML: duplicate tag <resumo> in file $inFile:$i.\n";
              exit;
            }
            $resumeCTRL = 1 ;
            $line =~ s/(<\w+>)/$tags{$1}/g ;
            next ;
        }

        if( $line =~ /<\/resumo>/ ) {
            if ($resumeCTRL == 0) {
              print STDOUT "Invalid XML: duplicate tag </resumo> in file $inFile:$i.\n";
              exit;
            }
            $resumeCTRL = 0 ;
            $line =~ s/(<\/\w+>)/$tags{$1}/g ;
            next ;
        }
        
        if( $resumeCTRL == 1) {
            print resFILE $line;
        }
        
	# Tratamento do <comando></comando> e <comandoNumerado></comandoNumerado>
        if( $line =~ /<comando>/ || $line =~ /<comandoNumerado>/ ) { 
            if ($comandoCTRL == 1) {
              print STDOUT "Invalid XML: duplicated tag in file $inFile:$i.\n";
              exit;
            }
            $comandoCTRL = 1;
            $line =~ s/(<\w+>)/$tags{$1}/g ;
            print $line ;
            next ;
        }
		
        if( $line =~ /<\/comando>/ || $line =~ /<\/comandoNumerado>/ ) {
            if ($comandoCTRL == 0) {
              print STDOUT "Invalid XML: duplicated tag in file $inFile:$i.\n";
              exit;
            }
            $comandoCTRL = 0;
            $line =~ s/(<\/\w+>)/$tags{$1}/g ;
            print $line ;
            next ;
        }

        if( $comandoCTRL == 1 ) {
            foreach( keys %reservedChars ) {
                if( $line =~ /$_/ ) { $line =~ s/$_/$reservedChars{$_}/g }
            }
            print $line ; 
            next ;
        }

        # Tratamento do <tabela></tabela>
        if( $line =~ /<tabela>/ ) {
            if ($tabelaCTRL == 1) {
              print STDOUT "Invalid XML: duplicated tag <tabela> in file $inFile:$i.\n";
              exit;
            }
            $tabelaCTRL = 1 ;
            $line =~ s/(<\w+>)/$tags{$1}/g ;
            print $line ;
            next ;
        }

        if( $line =~ /<\/tabela>/ ) {
            if ($tabelaCTRL == 0) {
              print STDOUT "Invalid XML: duplicated tag </tabela> in file $inFile:$i.\n";
              exit;
            }
            $tabelaCTRL = 0 ;
            $line =~ s/(<\/\w+>)/$tags{$1}/g ;
            print $line ;
            next ;
        }
		
	if( $tabelaCTRL == 1) {
            if( $line =~ /<legenda>/ ) {
                print "\\end{tabular}\n";
                $line =~ s/(<\w+>)/$tags{$1}/g ;
                $line =~ s/(<\/\w+>)/$tags{$1}/g ;
		print $line ;
		next ;
            }
        }
        
        # Substituicao da tag <arquivo> deve ser tratada como caso especial
        # para que o apostilator nao substitua caracteres estranhos a ele no
        # nome de arquivos das figuras
        if( $line =~ /<arquivob?>/ ) {
            $line =~ s/(<\/?\w+>)/$tags{$1}/g ;
            print $line ;
            next ;
        }

        # Ambiente matematico tambem tem que ser tratado como caso especial
        # para que os caracteres especias nao sejam alterados
        if( $line =~ /<math>/ ) {
            $line =~ s/(<\/?\w+>)/$tags{$1}/g ;
            print $line ;
            next ;
        }

        # Ambiente equation tambem tem que ser tratado como caso especial
        # para que os caracteres especias nao sejam alterados
        if( $line =~ /<equacao>/ ) {
            if ($equacaoCTRL == 1) {
              print STDOUT "Invalid XML: duplicated tag <equacao> in file $inFile:$i.\n";
              exit;
            }
            $equacaoCTRL = 1 ;
            $line =~ s/(<\w+>)/$tags{$1}/g ;
            print $line ;
            next ;
        }

        if( $line =~ /<\/equacao>/ ) {
            if ($equacaoCTRL == 0) {
              print STDOUT "Invalid XML: duplicated tag </equacao> in file $inFile:$i.\n";
              exit;
            }
            $equacaoCTRL = 0 ;
            $line =~ s/(<\/\w+>)/$tags{$1}/g ;
            print $line ;
            next ;
        }

        if( $equacaoCTRL == 1 )	{
            if( $line =~ /<\/?nome>/ ) {
                $line =~ s/(<\/?\w+>)/$tags{$1}/g ;
                print $line ;
                next ;
            } else {
                print $line ;
                next ;
            }
        }

        foreach( keys %strangeChars ) {
            $line =~ s/$_/$strangeChars{$_}/g ;
        }

        $line =~ s/\~/\\\~{}/g ;
        $line =~ s/\^/\\\^{}/g ;
        $line =~ s/(<\/?\w+\/?>)/$tags{$1}/g ;	
        $line =~ s/</\$<\$/g ;
        $line =~ s/>/\$>\$/g ;

        foreach( keys %mathChars ) {
            if( $line =~ /$_/ ) {
                $line =~ s/$_/$mathChars{$_}/g ;
            }
        }

	print $line ;
    }
	
    select STDOUT ;
    close inFILE ;
    close outFILE ;
    close resFILE ;
}

sub convert_latex2pdf() {
    if ("@_" == '1') {
      print "Converting to PDF: chapters.";
    } elsif ("@_" == '2') {
      print "Converting to PDF: bibliografy.";
    } elsif ("@_" == '3') { 
      print "Converting to PDF: indexes.";
    }
    chdir "$workdir/.tex";
    system( "pdflatex base.tex >> ../.apostilator.log 2>&1 &" );
    my $i = 0;
    while (system("pgrep pdflatex >/dev/null") == 0) {
      if ($i > 30) {
        print "\nWait for 30 seconds, aborting...";
        stop();
      }
      sleep(1);
      print ".";
    }
    print "\n";
    if (system("tail -n5 ../.apostilator.log | grep -q -e 'no output PDF file produced' -e 'PDF file is not finished'") == 0) {
        print "Apostilator-XML sintax error, more information on .apostilator.log.\n";
        exit;
    }
}
