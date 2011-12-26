# (un)install script for apostilator
# Written by Luiz C. B. Mostaço Guidolin - lcguid@apostilator.org
# report bugs at: bugs@apostilator.org

VERSION=`cat version`
DATA=`date +%Y%m%d-%H%M`

help:
	@echo -ne "\nUsage: make <target>\n\n"
	@echo -ne "Available targets are:\n"
	@echo -ne "\thelp\t\tto show this help\n"
	@echo -ne "\tinstall\t\tto install apostilator\n"
	@echo -ne "\tuninstall\tto uninstall apostilator\n"
	@echo -ne "\tclean\t\tto remove unnecessary files\n"
	@echo -ne "\tbackup\t\tbackup files\n"
	@echo -ne "\n"

install: clean
	@install -g root -o root -m 755 usr/bin/apostilator /usr/bin \
		&& echo -ne "[ok]\n" \
		|| echo -ne "[failed]\n"
	@mkdir /usr/share/doc/apostilator-${VERSION} \
		&& echo -ne "[ok]\n" \
		|| echo -ne "[failed]\n"
	@chmod 755 -R /usr/share/doc/apostilator-${VERSION} \
		&& echo -ne "[ok]\n" \
		|| echo -ne "[failed]\n"
	@cp -r usr/share/doc/apostilator/* /usr/share/doc/apostilator-${VERSION}/ \
		&& echo -ne "[ok]\n" \
		|| echo -ne "[failed]\n"
	@chown root:root -R /usr/share/doc/apostilator-${VERSION} \
		&& echo -ne "[ok]\n" \
		|| echo -ne "[failed]\n"
	@mkdir /usr/share/apostilator \
		&& echo -ne "[ok]\n" \
		|| echo -ne "[failed]\n"
	@chmod 755 /usr/share/apostilator \
		&& echo -ne "[ok]\n" \
		|| echo -ne "[failed]\n"
	@cp -r usr/share/apostilator/* /usr/share/apostilator/ \
		&& echo -ne "[ok]\n" \
		|| echo -ne "[failed]\n"
	@cp version /usr/share/apostilator/ \
		&& echo -ne "[ok]\n" \
		|| echo -ne "[failed]\n"
	@chown root:root -R /usr/share/apostilator \
		&& echo -ne "[ok]\n" \
		|| echo -ne "[failed]\n"
	@mkdir /usr/lib/apostilator \
		&& echo -ne "[ok]\n" \
		|| echo -ne "[failed]\n"
	@cp usr/lib/apostilator/libapostilator.ph /usr/lib/apostilator/ \
		&& echo -ne "[ok]\n" \
		|| echo -ne "[failed]\n"
	@chown root:root -R /usr/lib/apostilator \
		&& echo -ne "[ok]\n" \
		|| echo -ne "[failed]\n"
	@cp etc/apostilator.conf /etc/ \
		&& echo -ne "[ok]\n" \
		|| echo -ne "[failed]\n"
	@chown root:root /etc/apostilator.conf \
		&& echo -ne "[ok]\n" \
		|| echo -ne "[failed]\n"

uninstall:
	@rm /usr/bin/apostilator \
		&& echo -ne "removing binary:\t\t\t[ok]\n" \
		|| echo -ne "removing binary:\t\t\t[failed]\n"
	@rm -r /usr/share/doc/apostilator-*  \
		&& echo -ne "removind from /usr/doc:\t\t\t[ok]\n" \
		|| echo -ne "removind from /usr/doc:\t\t\t[failed]\n"
	@rm -r /usr/share/apostilator \
		&& echo -ne "removind from /usr/share:\t\t[ok]\n" \
		|| echo -ne "removind from /usr/share:\t\t[failed]\n"
	@rm -r /usr/lib/apostilator \
		&& echo -ne "removing from /usr/lib:\t\t\t[ok]\n" \
		|| echo -ne "removing from /usr/lib:\t\t\t[failed]\n"
	@rm /etc/apostilator.conf \
		&& echo -ne "removing configurations:\t\t[ok]\n" \
		|| echo -ne "removing configurations:\t\t[failed]\n"

clean:
	@echo -ne "\nRemoving trash:"
	@find . -name '*~' |xargs -n1 rm -f 2> /dev/null && echo -ne "\t[OK]\n"
	@echo -ne "\n"

release: clean
	@tar czf ../apostilator-${VERSION}.tar.gz ../apostilator

commit: clean
	cvs ci

backup: clean
	@tar czf ../${DATA}-apostilator-${VERSION}.tar.gz ../apostilator
