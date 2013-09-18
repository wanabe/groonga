EXTRA_DIST =					\
	CMakeLists.txt

AM_CFLAGS =			\
	-I$(top_builddir)	\
	-I$(top_srcdir)/include	\
	-I$(top_srcdir)/lib

AM_LDFLAGS =					\
	-avoid-version				\
	-module					\
	-no-undefined

LIBS =						\
	$(top_builddir)/lib/libgroonga.la

scaninfo_builders_plugins_LTLIBRARIES =
if WITH_MRUBY
scaninfo_builders_plugins_LTLIBRARIES += mruby.la
endif

include mruby_sources.am
mruby_la_CFLAGS = $(AM_CFLAGS) $(MRUBY_CFLAGS)
mruby_la_LIBADD = $(LIBS) $(MRUBY_LIBS)
mruby_la_LDFLAGS = $(AM_LDFLAGS) $(MRUBY_LDFLAGS)
