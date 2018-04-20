dnl Process this file with autoconf to produce a configure script.

AC_INIT(dotfive-greeter, 1.0.0)
AM_INIT_AUTOMAKE
AM_PROG_CC_C_O
AM_PROG_VALAC([0.24.0])

GLIB_GSETTINGS

dnl ###########################################################################
dnl Dependencies
dnl ###########################################################################

PKG_CHECK_MODULES(GREETER, [
    liblightdm-gobject-1
    gtk+-3.0
    webkitgtk-3.0
    dbus-glib-1
])

dnl ###########################################################################
dnl Configurable values
dnl ###########################################################################
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
dnl Files to generate
dnl ###########################################################################

AC_OUTPUT([
    Makefile
    data/Makefile
    po/Makefile
    src/Makefile
])

dnl ###########################################################################
dnl Summary
dnl ###########################################################################


echo "  ___     ___    _____   ___   ___  __   __  ___ ";
echo " |   \   / _ \  |_   _| | __| |_ _| \ \ / / | __|";
echo " | |) | | (_) |   | |   | _|   | |   \ V /  | _| ";
echo " |___/   \___/    |_|   |_|   |___|   \_/   |___|";
echo "                                                 ";
echo "  / __| | _ \ | __| | __| |_   _| | __| | _ \";
echo " | (_ | |   / | _|  | _|    | |   | _|  |   /";
echo "  \___| |_|_\ |___| |___|   |_|   |___| |_|_\";
echo "                                             ";
echo "
    Configuration directory:  $CONFIG_DIR
    Desktop directory:  $DESKTOP_DIR
"