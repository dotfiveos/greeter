greeter_PROGRAMS = lightdm-dotfive-greeter

dotfive_greeter_SOURCES = \
	dotfive-greeter.vala

dotfive_greeter_SOURCES = \
	$(GREETER_CFLAGS) \
	-w \
	-DGETTEXT_PACKAGE=\"$(GETTEXT_PACKAGE)\" \
	-DLOCALEDIR=\""$(localedir)"\" \
	-DVERSION=\"$(VERSION)\" \
	-DPKGDATADIR=\""$(pkgdatadir)"\"

dotfive_greeter_VALAFLAGS = \
	$(AM_VALAFLAGS) \
	--debug \
	--pkg posix \
	--pkg gtk+-3.0 \
	--pkg gdk-x11-3.0 \
	--pkg gio-unix-2.0 \
	--pkg x11 \
	--pkg liblightdm-gobject-1 \
	--pkg libcanberra \
	--pkg gio-2.0 \
	--pkg pixman-1 \
	--target-glib 2.32

dotfive_greeter_LDADD = \
	$(GREETER_LIBS) \
	-lm

DISTCLEANFILES = \
	Makefile.in