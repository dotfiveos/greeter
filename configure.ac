dnl Process this file with autoconf to produce a configure script.

AC_INIT(dotfive-greeter, 1.0.0)
AC_SUBST(THEME_DIR)
AC_CONFIG_MACRO_DIR(m4)
AM_INIT_AUTOMAKE([1.11 no-dist-gzip dist-xz foreign subdir-objects])
AM_PROG_CC_C_O
AM_PROG_VALAC([0.24.0])
AM_CONFIG_HEADER(config.h)
AM_MAINTAINER_MODE
m4_ifdef([AM_SILENT_RULES], [AM_SILENT_RULES(yes)])

GLIB_GSETTINGS

dnl ###########################################################################
dnl Dependencies
dnl ###########################################################################

PKG_CHECK_MODULES(DOTFIVE_GREETER, [
    gtk+-3.0
    gdk-x11-3.0
    liblightdm-gobject-1 >= 1.12.0
    freetype2
    cairo-ft
    libcanberra
    pixman-1
    x11
    xext
    webkit2gtk-4.0
])

dnl ###########################################################################
dnl Configurable values
dnl ###########################################################################
THEME_DIR="/usr/share/lightdm-dotfive/themes/"
AC_ARG_WITH(theme-dir,
            AS_HELP_STRING(--with-theme-dir=<path>,
                           Theme directory to use for webkit themes),
    if test x$withval != x; then
        THEME_DIR="$withval"
    fi
)
AC_SUBST(THEME_DIR)
AC_DEFINE_UNQUOTED(THEME_DIR, "$THEME_DIR", Theme Dir)

CONFIG_DIR="/etc/lightdm/"
AC_ARG_WITH(config-dir,
            AS_HELP_STRING(--with-config-dir=<path>,
                           Configuration directory of lightdm),
    if test x$withval != x; then
        CONFIG_DIR="$withval"
    fi
)
AC_SUBST(CONFIG_DIR)
AC_DEFINE_UNQUOTED(CONFIG_DIR, "$CONFIG_DIR", Config Dir)

DESKTOP_DIR="/usr/share/xgreeters/"
AC_ARG_WITH(desktop-dir,
            AS_HELP_STRING(--with-desktop-dir=<path>,
                           Desktop directory of lightdm),
    if test x$withval != x; then
        DESKTOP_DIR="$withval"
    fi
)
AC_SUBST(DESKTOP_DIR)
AC_DEFINE_UNQUOTED(DESKTOP_DIR, "$DESKTOP_DIR", Desktop Dir)

dnl ###########################################################################
dnl Internationalization
dnl ###########################################################################

IT_PROG_INTLTOOL(0.35.0)
GETTEXT_PACKAGE=lightdm-dotfive-greeter
AC_DEFINE_UNQUOTED(GETTEXT_PACKAGE, "$GETTEXT_PACKAGE", Gettext package)

dnl ###########################################################################
dnl Check for GTK version - 3.20
dnl ###########################################################################

PKG_CHECK_MODULES(GTK_3_20_0, gtk+-3.0 >= 3.20.0 , gtk_check_pass=yes, gtk_check_pass=no)
if test x$gtk_check_pass = xyes ; then
  AM_VALAFLAGS="$AM_VALAFLAGS -D HAVE_GTK_3_20_0"
  AC_SUBST([AM_VALAFLAGS])
fi

dnl ###########################################################################
dnl Hack for vala >= 0.39
dnl ###########################################################################

SLICK_GREETER_CFLAGS="$SLICK_GREETER_CFLAGS -include gtk/gtkx.h"
AC_SUBST([SLICK_GREETER_CFLAGS])

dnl ###########################################################################
dnl Files to generate
dnl ###########################################################################

AC_CONFIG_FILES([
    Makefile
    data/Makefile
    po/Makefile.in
    src/Makefile
    themes/Makefile
    themes/dotfive/Makefile
])
AC_OUTPUT

dnl ###########################################################################
dnl Summary
dnl ###########################################################################


echo "  ___     ___    _____   ___   ___  __   __  ___ ";
echo " |   \\   / _ \\  |_   _| | __| |_ _| \\ \\ / / | __|";
echo " | |) | | (_) |   | |   | _|   | |   \\ V /  | _| ";
echo " |___/   \\___/    |_|   |_|   |___|   \\_/   |___|";
echo "   ___   ___   ___   ___   _____   ___   ___ ";
echo "  / __| | _ \\ | __| | __| |_   _| | __| | _ \\";
echo " | (_ | |   / | _|  | _|    | |   | _|  |   /";
echo "  \\___| |_|_\\ |___| |___|   |_|   |___| |_|_\\";
echo "
    Configuration directory:  $CONFIG_DIR
    Theme directory:          $THEME_DIR
    Desktop directory:        $DESKTOP_DIR
"