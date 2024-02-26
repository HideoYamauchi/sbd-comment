SUBDIRS = src agent man tests

# .gz because github doesn't support .xz yet :-(
# this is modified
#
TAG		?= $(shell git log --pretty="format:%H" -n 1 || sed -n -e "s/%global longcommit\s*//p" sbd.spec)$(shell test -n "$$(git status -s)" && echo -n "-mod")
SPEC_VERSION	?= $(shell sed -n -e "s/Version:\s*//p" sbd.spec)
distdir		 = $(PACKAGE)-$(TAG)
TARFILE		 = $(distdir).tar.gz
DIST_ARCHIVES	 = $(TARFILE)
KEEP_EXISTING_TAR = no
INJECT_GIT_COMMIT = yes
CLEANFILES       = *.rpm *.tar.* sbd-*
DISTCLEANFILES   = sbd-* sbd-*/

RPM_ROOT	= $(shell pwd)
RPM_OPTS	= --define "_sourcedir $(RPM_ROOT)" 	\
		  --define "_specdir   $(RPM_ROOT)" 	\
		  --define "_srcrpmdir $(RPM_ROOT)"     \
		  --define "_builddir  $(RPM_ROOT)"     \
		  --define "_rpmdir    $(RPM_ROOT)"

MOCK_TARGET     ?= rhel-7.1-candidate-x86_64
MOCK_OPTIONS	?= --resultdir=$(RPM_ROOT)/mock --no-cleanup-after

BUILD_COUNTER	?= build.counter
COUNT           = $(shell expr 1 + 0$(shell cat $(BUILD_COUNTER)))

COMMIT_COUNTER	?= $(shell git describe --tags --long --always --match v$(SPEC_VERSION) | cut -f 2 -d- -s)

TESTS           = tests/regressions.sh
export SBD_BINARY := src/sbd
export SBD_PRELOAD := tests/.libs/libsbdtestbed.so
export SBD_USE_DM ?= no
export SBD_TRANSLATE_AIO ?= no

EXTRA_DIST      = sbd.spec tests/regressions.sh man/sbd.8.pod.in

pkgconfigdir	= $(datadir)/pkgconfig
pkgconfig_DATA	= sbd.pc

export:
	rm -f $(PACKAGE)-HEAD.tar.*
	if test "$(KEEP_EXISTING_TAR)" != "yes"; then \
	    rm -f $(TARFILE); \
	fi;
	! (git status -s | grep "??" && echo "untracked files present in git-repo" )
	if [ -f $(TARFILE) ]; then						\
	    echo `date`: Using existing tarball: $(TARFILE);			\
	else									\
	    rm -f $(PACKAGE).tar.*;                                             \
	    (git archive --prefix=$(distdir)/ $(shell echo $(TAG)|cut -f1 -d-) || tar -c --transform="s,^,$(distdir)/," --exclude="*.tar.*" --exclude="$(distdir)" --exclude="*.o" --exclude="*.8" --exclude="config.*" --exclude="libtool" --exclude="ltmain.sh*" --exclude="Makefile" --exclude="Makefile.in" --exclude="stamp-*" --exclude="*.service" --exclude="sbd" --exclude="*.m4" --exclude="*.cache" --exclude="configure" --exclude="*.list" --exclude="depcomp" --exclude="install-sh" --exclude="missing" --exclude="compile" --exclude="sbd.sh" --exclude="sbd.sysconfig" --exclude="~" --exclude="*.swp" --exclude="*.patch" --exclude="*.diff" --exclude="*.orig" --exclude="*.rej" --exclude="*.rpm" --exclude="*.pod" --exclude=".deps" --exclude="test-driver" --exclude="sbd.pc" --exclude="build.counter" *) | gzip > $(TARFILE);	\
	    if test -n "$$(git status -s)" || test "$(INJECT_GIT_COMMIT)" = "yes"; then \
		if test -n "$$(git status -s)"; then git diff HEAD --name-only|grep -v "^\."|xargs -n1 git diff HEAD > uncommitted.diff; fi; \
		rm -rf $(distdir); tar -xzf $(TARFILE); rm $(TARFILE); \
		cd $(distdir); \
		if test -n "$$(git status -s)"; then patch -p1 -i ../uncommitted.diff; fi; \
		cd ..; \
		sed -i 's/global\ commit.*/global\ commit\ $(TAG)/' $(distdir)/$(PACKAGE).spec; \
		tar -czf $(TARFILE) $(distdir); rm -rf $(distdir); \
		rm -f uncommitted.diff; \
	    fi; \
	    echo `date`: Rebuilt $(TARFILE);					\
	fi

#replace commit id in sbd.spec
spec:
	rm -f *.src.rpm
	rm -rf $(distdir)
	mkdir $(distdir)
	cp $(PACKAGE).spec $(distdir)
	sed -i 's/global\ longcommit.*/global\ longcommit\ $(TAG)/' $(distdir)/$(PACKAGE).spec
	if [ -e $(BUILD_COUNTER) ]; then \
		sed -i 's/global\ build_counter.*/global\ build_counter\ $(COUNT)/' $(distdir)/$(PACKAGE).spec; \
		echo $(COUNT) > $(BUILD_COUNTER); \
	fi
	if [ -n "$(COMMIT_COUNTER)" ]; then \
		sed -i 's/global\ commit_counter.*/global\ commit_counter\ $(COMMIT_COUNTER)/' $(distdir)/$(PACKAGE).spec; \
	fi

srpm:	export spec
	rpmbuild $(RPM_OPTS) -bs $(distdir)/$(PACKAGE).spec

rpm:	export spec
	rpmbuild $(RPM_OPTS) -ba $(distdir)/$(PACKAGE).spec

mock:   srpm
	-rm -rf $(RPM_ROOT)/mock
	@echo "mock --root=$* --rebuild $(MOCK_OPTIONS) $(RPM_ROOT)/*.src.rpm"
	mock --root=$(MOCK_TARGET) --rebuild $(MOCK_OPTIONS) $(RPM_ROOT)/*.src.rpm

beekhof: mock
	cluster-helper -- 'rm -f sbd-*.x86_64.rpm'
	cluster-helper --copy $(RPM_ROOT)/mock/sbd-*.x86_64.rpm {}: 
	cluster-helper -- yum install -y sbd-*.x86_64.rpm

