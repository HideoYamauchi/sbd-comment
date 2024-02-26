dist_man_MANS	= sbd.8

DISTCLEANFILES = sbd.8.pod sbd.8 sbd.sysconfig.pod

sbd.sysconfig.pod: ../src/sbd.sysconfig
	sed -r -n -e "s/^## Type: (.*)/Allows C<\1>/;t type;s/^## Default: (.*)/ defaulting to C<\1>/;t default;s/^#*(.*)=.*/=item B<\1>\n/;t variable;s/^#*//;s/^ *//;H;d;:type;h;d;:default;H;x;s/\n//;x;d;:variable;G;p" $< > $@

sbd.8.pod: sbd.8.pod.in sbd.sysconfig.pod
	sed -e "s,\@runstatedir\@,$(runstatedir),;s,\@configdir\@,$(CONFIGDIR)," $< |sed -e "s/@environment_section@//;t insert;p;d;:insert;rsbd.sysconfig.pod" > $@

sbd.8:	sbd.8.pod
	@POD2MAN@ -s 8 -c "STONITH Block Device" -r "SBD" -n "SBD" $< $@

