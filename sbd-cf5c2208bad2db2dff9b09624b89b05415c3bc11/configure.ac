dnl
dnl autoconf for Agents
dnl
dnl License: GNU General Public License (GPL)

dnl ===============================================
dnl Bootstrap 
dnl ===============================================
AC_PREREQ(2.63)

dnl Suggested structure:
dnl     information on the package
dnl     checks for programs
dnl     checks for libraries
dnl     checks for header files
dnl     checks for types
dnl     checks for structures
dnl     checks for compiler characteristics
dnl     checks for library functions
dnl     checks for system services

AC_INIT([sbd], 
	[1.5.2],
	[lmb@suse.com])
m4_include([tests-opt.m4])
AC_CANONICAL_HOST
AC_CONFIG_AUX_DIR(.)
AC_CONFIG_HEADERS(config.h)
m4_ifdef([AM_SILENT_RULES],[AM_SILENT_RULES([no])])
AM_INIT_AUTOMAKE(1.11.1 foreign TESTS_OPTION)
LT_INIT([dlopen],[disable-static])
AM_PROG_CC_C_O

# expand_path_option $path_variable_name $default
expand_path_option() {
    # The first argument is the variable *name* (not value)
    ac_path_varname="$1"

    # Get the original value of the variable
    ac_path_value=$(eval echo "\${${ac_path_varname}}")

    # Expand any literal variable expressions in the value so that we don't
    # end up with something like '${prefix}' in #defines etc.
    #
    # Autoconf deliberately leaves values unexpanded to allow overriding
    # the configure script choices in make commands (for example,
    # "make exec_prefix=/foo install"). No longer being able to do this seems
    # like no great loss.
    eval ac_path_value=$(eval echo "${ac_path_value}")

    # Use (expanded) default if necessary
    AS_IF([test x"${ac_path_value}" = x""],
	  [eval ac_path_value=$(eval echo "$2")])

    # Require a full path
    AS_CASE(["$ac_path_value"],
            [/*], [eval ${ac_path_varname}="$ac_path_value"],
            [*], [AC_MSG_ERROR([$ac_path_varname value "$ac_path_value" is not a full path])]
    )
}

PKG_CHECK_MODULES(glib, [glib-2.0])
PKG_CHECK_MODULES(libxml, [libxml-2.0])

PKG_CHECK_MODULES(cmap, [libcmap], HAVE_cmap=1, HAVE_cmap=0)
PKG_CHECK_MODULES(votequorum, [libvotequorum], HAVE_votequorum=1, HAVE_votequorum=0)

dnl pacemaker > 1.1.8
PKG_CHECK_MODULES(pacemaker, [pacemaker, pacemaker-cib], HAVE_pacemaker=1, HAVE_pacemaker=0)

dnl pacemaker <= 1.1.8
PKG_CHECK_MODULES(pcmk, [pcmk, pcmk-cib], HAVE_pcmk=1, HAVE_pcmk=0)

PKG_CHECK_MODULES(libqb, [libqb])

CPPFLAGS="$CPPFLAGS -Werror $glib_CFLAGS $libxml_CFLAGS"
LIBS="$LIBS $glib_LIBS $libxml_LIBS"

if test $HAVE_pacemaker = 0 -a $HAVE_pcmk = 0; then
    AC_MSG_ERROR(No package 'pacemaker' found)
elif test $HAVE_pacemaker = 1; then
    CPPFLAGS="$CPPFLAGS $glib_CFLAGS $pacemaker_CFLAGS"
    if test $HAVE_cmap = 0; then
        AC_MSG_NOTICE(No library 'cmap' found)
    else
        CPPFLAGS="$CPPFLAGS $cmap_CFLAGS"
        LIBS="$LIBS $cmap_LIBS"
    fi
    if test $HAVE_votequorum = 0; then
        AC_MSG_NOTICE(No library 'votequorum' found)
    else
        CPPFLAGS="$CPPFLAGS $votequorum_CFLAGS"
        LIBS="$LIBS $votequorum_LIBS"
    fi
fi

CPPFLAGS="$CPPFLAGS $libqb_CFLAGS $pacemaker_CFLAGS $pcmk_CFLAGS"
LIBS="$LIBS $libqb_LIBS $pacemaker_LIBS $pcmk_LIBS"

dnl     checks for libraries
AC_CHECK_LIB(c, dlopen)                         dnl if dlopen is in libc...
AC_CHECK_LIB(dl, dlopen)                        dnl -ldl (for Linux)
AC_CHECK_LIB(aio, io_setup, , missing="yes")
AC_CHECK_LIB(qb, qb_ipcs_connection_auth_set, , missing="yes")
AC_CHECK_LIB(cib, cib_new, , missing="yes")
AC_CHECK_LIB(crmcommon, set_crm_log_level, , missing="yes")
AC_CHECK_LIB(pe_status, pe_find_node, , missing="yes")
AC_CHECK_LIB(pe_rules, test_rule, , missing="yes")
AC_CHECK_LIB(crmcluster, crm_peer_init, , missing="yes")
AC_CHECK_LIB(uuid, uuid_unparse, , missing="yes")
AC_CHECK_LIB(cmap, cmap_initialize, , HAVE_cmap=0)
AC_CHECK_LIB(votequorum, votequorum_getinfo, , HAVE_votequorum=0)
AC_CHECK_LIB(crmcommon, pcmk_pacemakerd_api_ping, HAVE_pacemakerd_api=1, HAVE_pacemakerd_api=0)

dnl pacemaker >= 1.1.8
AC_CHECK_HEADERS(crm/cluster.h)
AC_CHECK_LIB(crmcommon, pcmk_strerror, , missing="yes")
AC_CHECK_LIB(cib, cib_apply_patch_event, , missing="yes")

dnl pacemaker-2.0 removed support for corosync 1 cluster layer
AC_CHECK_DECLS([pcmk_cluster_classic_ais, pcmk_cluster_cman],,,
               [#include <pacemaker/crm/cluster.h>])

dnl check for additional no-quorum-policies
dnl AC_TEST_NO_QUORUM_POLICY(POLICY)
AC_DEFUN([AC_TEST_NO_QUORUM_POLICY],[
    AC_MSG_CHECKING([whether enum pe_quorum_policy defines value $1])
    AC_LANG_PUSH([C])
    AC_COMPILE_IFELSE([AC_LANG_PROGRAM(
        [#include <pacemaker/crm/pengine/pe_types.h>],
        [enum pe_quorum_policy policy = $1; return policy;])],
            AC_DEFINE_UNQUOTED(m4_toupper(HAVE_ENUM_$1), 1,
            [Does pe_types.h have $1 value in enum pe_quorum_policy?])
            AC_MSG_RESULT([yes]), AC_MSG_RESULT([no]))
    AC_LANG_POP([C])
])
AC_TEST_NO_QUORUM_POLICY(no_quorum_demote)

dnl check for new pe-API
AC_CHECK_FUNCS(pe_new_working_set)

dnl check if votequorum comes with default for qdevice-sync_timeout
AC_CHECK_DECLS([VOTEQUORUM_QDEVICE_DEFAULT_SYNC_TIMEOUT],
               HAVE_DECL_VOTEQUORUM_QDEVICE_DEFAULT_SYNC_TIMEOUT=1,
               HAVE_DECL_VOTEQUORUM_QDEVICE_DEFAULT_SYNC_TIMEOUT=0,
               [#include <corosync/votequorum.h>])

if test "$missing" = "yes"; then
   AC_MSG_ERROR([Missing required libraries or functions.])
fi

AC_PATH_PROGS(POD2MAN, pod2man, pod2man)

AC_ARG_ENABLE([shared-disk],
[  --enable-shared-disk Turn on functionality that requires shared disk
     [default=yes]])

DISK=0
if test "x${enable_shared_disk}" != xno ; then
   DISK=1
fi

AC_DEFINE_UNQUOTED(SUPPORT_SHARED_DISK, $DISK, Turn on functionality that requires shared disk)
AM_CONDITIONAL(SUPPORT_SHARED_DISK, test "$DISK" = "1")

if
	test -e /proc/$$
then
	echo "/proc/{pid} is supported" 
	AC_DEFINE_UNQUOTED(HAVE_PROC_PID, 1, Define to 1 if /proc/{pid} is supported.)
fi

AC_DEFINE_UNQUOTED(CHECK_TWO_NODE, $HAVE_cmap, Turn on checking for 2-node cluster)
AM_CONDITIONAL(CHECK_TWO_NODE, test "$HAVE_cmap" = "1")

AC_DEFINE_UNQUOTED(CHECK_VOTEQUORUM_HANDLE, $HAVE_votequorum, Turn on periodic checking of votequorum-handle)
AM_CONDITIONAL(CHECK_VOTEQUORUM_HANDLE, test "$HAVE_votequorum" = "1")

AC_DEFINE_UNQUOTED(CHECK_QDEVICE_SYNC_TIMEOUT,
                   ($HAVE_DECL_VOTEQUORUM_QDEVICE_DEFAULT_SYNC_TIMEOUT && $HAVE_cmap),
                   Turn on checking if watchdog-timeout and qdevice-sync_timeout are matching)
AM_CONDITIONAL(CHECK_QDEVICE_SYNC_TIMEOUT,
               test "$HAVE_DECL_VOTEQUORUM_QDEVICE_DEFAULT_SYNC_TIMEOUT" = "1" &&
               test "$HAVE_cmap" = "1")

AC_DEFINE_UNQUOTED(USE_PACEMAKERD_API, $HAVE_pacemakerd_api, Turn on synchronization between sbd & pacemakerd)
AM_CONDITIONAL(USE_PACEMAKERD_API, test "$HAVE_pacemakerd_api" = "1")

CONFIGDIR=""
AC_ARG_WITH(configdir,
    [  --with-configdir=DIR
       Directory for SBD configuration file [${CONFIGDIR}]],
    [ CONFIGDIR="$withval" ]
)

dnl --runstatedir is available as of autoconf 2.70 (2020-12-08). When users
dnl have an older version, they can use our --with-runstatedir.
sbd_runstatedir=""
AC_ARG_WITH([runstatedir],
    [AS_HELP_STRING([--with-runstatedir=DIR],
        [modifiable per-process data @<:@LOCALSTATEDIR/run@:>@])],
    [ sbd_runstatedir="$withval" ]
)

SBD_WATCHDOG_TIMEOUT_DEFAULT=""
AC_ARG_WITH(watchdog-timeout-default,
    [  --with-watchdog-timeout-default=SECONDS
       Timeout in seconds SBD will configure the watchdog per default],
    [ SBD_WATCHDOG_TIMEOUT_DEFAULT="$withval" ]
)

SBD_SYNC_RESOURCE_STARTUP_DEFAULT=""
AC_ARG_WITH(sync-resource-startup-default,
    [  --with-sync-resource-startup-default=yes|no
       Default for SBD_SYNC_RESOURCE_STARTUP if not given in SBD configuration file explicitly],
    [ SBD_SYNC_RESOURCE_STARTUP_DEFAULT="$withval" ]
)

SBD_SYNC_RESOURCE_STARTUP_SYSCONFIG=""
AC_ARG_WITH(sync-resource-startup-sysconfig,
    [  --with-sync-resource-startup-sysconfig=yes|no
       Value for SBD_SYNC_RESOURCE_STARTUP going into template SBD configuration file],
    [ SBD_SYNC_RESOURCE_STARTUP_SYSCONFIG="$withval" ]
)

#
# Where is dlopen?
#
if test "$ac_cv_lib_c_dlopen" = yes; then
    LIBADD_DL=""
elif test "$ac_cv_lib_dl_dlopen" = yes; then
    LIBADD_DL=-ldl
else
    LIBADD_DL=${lt_cv_dlopen_libs}
fi


dnl **********************************************************************
dnl Check for various argv[] replacing functions on various OSs
dnl
dnl Borrowed from Proftpd
dnl Proftpd is Licenced under the terms of the GNU General Public Licence
dnl and is available from http://www.proftpd.org/
dnl

AC_CHECK_FUNCS(setproctitle)
AC_CHECK_HEADERS(libutil.h)
AC_CHECK_LIB(util, setproctitle,
        [AC_DEFINE(HAVE_SETPROCTITLE,1,[ ])
                ac_cv_func_setproctitle="yes" ; LIBS="$LIBS -lutil"])

if test "$ac_cv_func_setproctitle" = "yes"; then
  pf_argv_set="PF_ARGV_NONE"
fi

if test "$pf_argv_set" = ""; then
  AC_CHECK_HEADERS(sys/pstat.h)
  if test "$ac_cv_header_pstat_h" = "yes"; then
    AC_CHECK_FUNCS(pstat)

    if test "$ac_cv_func_pstat" = "yes"; then
        pf_argv_set="PF_ARGV_PSTAT"
    else
        pf_argv_set="PF_ARGV_WRITEABLE"
    fi
  fi

  if test "$pf_argv_set" = ""; then
    AC_EGREP_HEADER([#define.*PS_STRINGS.*],sys/exec.h,
                        have_psstrings="yes",have_psstrings="no")
    if test "$have_psstrings" = "yes"; then
        pf_argv_set="PF_ARGV_PSSTRINGS"
    fi
  fi

  if test "$pf_argv_set" = ""; then
    AC_CACHE_CHECK(whether __progname and __progname_full are available,
                    pf_cv_var_progname,
                    AC_TRY_LINK([extern char *__progname, *__progname_full;],
                        [__progname = "foo"; __progname_full = "foo bar";],
                        pf_cv_var_progname="yes", pf_cv_var_progname="no"))

    if test "$pf_cv_var_progname" = "yes"; then
        AC_DEFINE(HAVE___PROGNAME,1,[ ])
    fi

    AC_CACHE_CHECK(which argv replacement method to use,
                    pf_cv_argv_type,
                    AC_EGREP_CPP(yes,[
#if defined(__GNU_HURD__)
  yes
#endif
  ],pf_cv_argv_type="new", pf_cv_argv_type="writeable"))

    if test "$pf_cv_argv_type" = "new"; then
        pf_argv_set="PF_ARGV_NEW"
    fi

    if test "$pf_argv_set" = ""; then
        pf_argv_set="PF_ARGV_WRITEABLE"
    fi
  fi
fi
AC_DEFINE_UNQUOTED(PF_ARGV_TYPE, $pf_argv_set,
        mechanism to pretty-print ps output: setproctitle-equivalent)

dnl End of tests borrowed from Proftpd

AC_MSG_NOTICE(Sanitizing prefix: ${prefix})
case $prefix in
  NONE)
	prefix=/usr
	dnl Fix default variables - "prefix" variable if not specified
	if test "$localstatedir" = "\${prefix}/var"; then
		localstatedir="/var"
	fi
	if test "$sysconfdir" = "\${prefix}/etc"; then
		sysconfdir="/etc"
	fi
	;;
esac

AC_MSG_NOTICE(Sanitizing exec_prefix: ${exec_prefix})
case $exec_prefix in
  dnl For consistency with Heartbeat, map NONE->$prefix
  NONE)	  exec_prefix=$prefix;;
  prefix) exec_prefix=$prefix;;
esac

dnl Expand values of autoconf-provided directory options
expand_path_option prefix
expand_path_option exec_prefix
expand_path_option bindir
expand_path_option sbindir
expand_path_option libexecdir
expand_path_option datadir
expand_path_option sysconfdir
expand_path_option sharedstatedir
expand_path_option localstatedir
expand_path_option libdir
expand_path_option includedir
expand_path_option oldincludedir
expand_path_option infodir
expand_path_option mandir

AS_IF([test x"${runstatedir}" = x""], [runstatedir="${sbd_runstatedir}"],
      [test x"${sbd_runstatedir}" != x""], [
      echo "--with-runstatedir=${sbd_runstatedir} is taking precedence"
      echo "over runstatedir=${runstatedir}."
      echo "Consider using --runstatedir=${sbd_runstatedir} directly or let it"
      echo "go with the default."
      runstatedir="${sbd_runstatedir}"])
expand_path_option runstatedir "${localstatedir}/run"
AC_SUBST(runstatedir)

AC_SUBST(LIBADD_DL)        dnl extra flags for dynamic linking libraries

expand_path_option CONFIGDIR "${sysconfdir}/sysconfig"
AC_SUBST(CONFIGDIR)

if test x"${SBD_WATCHDOG_TIMEOUT_DEFAULT}" = x""; then
    case "$host_cpu" in
        s390|s390x)
            SBD_WATCHDOG_TIMEOUT_DEFAULT=15
            ;;
        *)
            SBD_WATCHDOG_TIMEOUT_DEFAULT=5
            ;;
    esac
fi
AC_SUBST(SBD_WATCHDOG_TIMEOUT_DEFAULT)
AC_DEFINE_UNQUOTED(SBD_WATCHDOG_TIMEOUT_DEFAULT, $SBD_WATCHDOG_TIMEOUT_DEFAULT,
    Timeout in seconds SBD will configure the watchdog per default)

if test x"${SBD_SYNC_RESOURCE_STARTUP_DEFAULT}" = x""; then
    SBD_SYNC_RESOURCE_STARTUP_DEFAULT=yes
fi
AC_SUBST(SBD_SYNC_RESOURCE_STARTUP_DEFAULT)
dnl rather pass to C as a string and interpret there for consistent interpretation
AC_DEFINE_UNQUOTED(SBD_SYNC_RESOURCE_STARTUP_DEFAULT, "${SBD_SYNC_RESOURCE_STARTUP_DEFAULT}",
    Default for SBD_SYNC_RESOURCE_STARTUP if not given in SBD configuration file explicitly)

if test x"${SBD_SYNC_RESOURCE_STARTUP_SYSCONFIG}" = x""; then
    SBD_SYNC_RESOURCE_STARTUP_SYSCONFIG=${SBD_SYNC_RESOURCE_STARTUP_DEFAULT}
fi
AC_SUBST(SBD_SYNC_RESOURCE_STARTUP_SYSCONFIG)

dnl The Makefiles and shell scripts we output
AC_CONFIG_FILES([Makefile src/Makefile agent/Makefile man/Makefile tests/Makefile agent/sbd src/sbd.service src/sbd_remote.service src/sbd.sh src/sbd.sysconfig sbd.pc])

dnl Now process the entire list of files added by previous 
dnl  calls to AC_CONFIG_FILES()
AC_OUTPUT()
