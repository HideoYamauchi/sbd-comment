#!/bin/sh

am_ver=`automake --version | sed -n 1p`
case $am_ver in
    *\ 1.11*|*\ 1.12*) echo 'm4_define([TESTS_OPTION], [])';;
    *) echo 'm4_define([TESTS_OPTION], [serial-tests])';;
esac > tests-opt.m4
cat tests-opt.m4
# Run this to generate all the initial makefiles, etc.
autoreconf -i -v && echo Now run ./configure and make
