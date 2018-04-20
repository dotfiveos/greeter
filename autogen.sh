srcdir=`dirname $0`
test -z "$srcdir" && srcdir=.

PKG_NAME="lightdm-dotfive-greeter"
REQUIRED_AUTOMAKE_VERSION=1.7

(test -f $srcdir/configure.ac \
  && test -d $srcdir/src) || {
    echo -n "**Error**: Directory "\`$srcdir\'" does not look like the"
    echo " top-level lightdm-dotfive-greeter directory"
    exit 1
}

which gnome-autogen.sh || {
    echo "You need to install gnome-common from the GNOME CVS"
    exit 1
}
. gnome-autogen.sh