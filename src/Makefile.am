
sbin_PROGRAMS = lightdm-dotfive-greeter
# greeter_PROGRAMS = lightdm-dotfive-greeter
# greeterdir= /usr/bin/

lightdm_dotfive_greeter_SOURCES = \
	config.vapi \
	fixes.vapi \
	javascriptcore.vapi \
	main-window.vala \
	dotfive-greeter.vala

lightdm_dotfive_greeter_CFLAGS = \
	$(DOTFIVE_GREETER_CFLAGS) \
	-w \
	-DGETTEXT_PACKAGE=\"$(GETTEXT_PACKAGE)\" \
	-DLOCALEDIR=\""$(localedir)"\" \
	-DVERSION=\"$(VERSION)\" \
	-DPKGDATADIR=\""$(pkgdatadir)"\"

lightdm_dotfive_greeter_VALAFLAGS = \
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
	--pkg webkit2gtk-4.0 \
	--pkg javascriptcoregtk-3.0 \
	--vapidir=. \
	--target-glib 2.32

lightdm_dotfive_greeter_LDADD = \
	$(DOTFIVE_GREETER_LIBS) \
	-lm

lightdm_dotfive_greeter_vala.stamp: $(top_srcdir)/config.h

DISTCLEANFILES = \
	Makefile.in