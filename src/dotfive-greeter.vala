using GLib;
using Gtk;
using Cairo;
using WebKit;

public class DotfiveGreeter {
    
    public static DotfiveGreeter instance;

    public bool testmode = false;

    public signal void show_message (string text, LightDM.MessageType type);
    public signal void show_prompt (string text, LightDM.PromptType type);
    public signal void authentication_complete ();
    public signal void starting_session ();

    private Cairo.XlibSurface background_surface;
    private MainWindow main_window;

    private LightDM.Greeter greeter;

    private static Timer log_timer;

    private DotfiveGreeter (bool _testmode) {
        instance = this;
        testmode = _testmode;

        debug ("Creating background surface");
        background_surface = create_root_surface (Gdk.Screen.get_default ());

        debug ("Creating lightdm greeter instance");
        greeter = new LightDM.Greeter ();
        
        greeter.show_message.connect ((text, type) => {
            show_message (text, type);
        });
        
        greeter.show_prompt.connect ((text, type) => {
            show_prompt (text, type);
        });
        
        greeter.autologin_timer_expired.connect (() => {
            greeter.authenticate_autologin ();
        });
        
        greeter.authentication_complete.connect (() => {
            authentication_complete ();
        });

        var connected = false;
        try {
            connected = greeter.connect_to_daemon_sync ();
        } catch (Error e) {
            warning ("Failed to connect to LightDM daemon: %s", e.message);
        }

        if (!connected && !testmode) {
            Posix.exit (Posix.EXIT_FAILURE);
        }

        // var view = new WebView();

        main_window = new MainWindow ();
        // main_window.destroy.connect(() => { kill_fake_wm (); });
        main_window.delete_event.connect(() => {
            Gtk.main_quit();
            return false;
        });

        Bus.own_name (BusType.SESSION, "x.dm.DotfiveGreeter", BusNameOwnerFlags.NONE);

        var view = new WebView();
        view.open("https://google.com/");
        main_window.add(view);        

    }

    public void show () {

    }

    private static Cairo.XlibSurface? create_root_surface (Gdk.Screen screen) {
        var visual = screen.get_system_visual ();

        unowned X.Display display = (screen.get_display () as Gdk.X11.Display).get_xdisplay ();
        unowned X.Screen xscreen = (screen as Gdk.X11.Screen).get_xscreen ();

        var pixmap = X.CreatePixmap (display,
                                     (screen.get_root_window () as Gdk.X11.Window).get_xid (),
                                     xscreen.width_of_screen (),
                                     xscreen.height_of_screen (),
                                     visual.get_depth ());

        // Convert into a Cairo surface 
        var surface = new Cairo.XlibSurface (display,
                                             pixmap,
                                             (visual as Gdk.X11.Visual).get_xvisual (),
                                             xscreen.width_of_screen (), xscreen.height_of_screen ());

        return surface;
    }
    
    private static void log_cb (string? log_domain, LogLevelFlags log_level, string message) {
        string prefix;
        switch (log_level & LogLevelFlags.LEVEL_MASK) {
            case LogLevelFlags.LEVEL_ERROR:
                prefix = "ERROR:";
                break;
            case LogLevelFlags.LEVEL_CRITICAL:
                prefix = "CRITICAL:";
                break;
            case LogLevelFlags.LEVEL_WARNING:
                prefix = "WARNING:";
                break;
            case LogLevelFlags.LEVEL_MESSAGE:
                prefix = "MESSAGE:";
                break;
            case LogLevelFlags.LEVEL_INFO:
                prefix = "INFO:";
                break;
            case LogLevelFlags.LEVEL_DEBUG:
                prefix = "DEBUG:";
                break;
            default:
                prefix = "LOG:";
                break;
        }

        stderr.printf ("[%+.2fs] %s %s\n", log_timer.elapsed (), prefix, message);
    }

    public static int main (string[] args) {

        // prevents meory from being paged, used to prevent passwords from being saved
        Posix.mlockall (Posix.MCL_CURRENT | Posix.MCL_FUTURE);

        // Initialize localization
        Intl.setlocale (LocaleCategory.ALL, "");
        Intl.bindtextdomain (Config.GETTEXT_PACKAGE, Config.LOCALEDIR);
        Intl.bind_textdomain_codeset (Config.GETTEXT_PACKAGE, "UTF-8");
        Intl.textdomain (Config.GETTEXT_PACKAGE);

        log_timer = new Timer ();
        Log.set_default_handler (log_cb);
        
        debug("Starting greeter!");

        // Allows the DE to set cursor
        GLib.Environment.set_variable ("GDK_CORE_DEVICE_EVENTS", "1", true);

        Gtk.init (ref args);

        debug ("Starting lightdm-dotfive-greeter %s UID=%d LANG=%s", Config.VERSION, (int) Posix.getuid (), Environment.get_variable ("LANG"));

        debug ("Setting cursor");
        Gdk.get_default_root_window ().set_cursor (new Gdk.Cursor.for_display (Gdk.Display.get_default (), Gdk.CursorType.LEFT_PTR));

        // Setting gtk settings (required?)
        /*debug ("Setting GTK+ settings");
        var settings = Gtk.Settings.get_default ();
        var value = UGSettings.get_string (UGSettings.KEY_THEME_NAME);
        if (value != "")
            settings.set ("gtk-theme-name", value, null);
        value = UGSettings.get_string (UGSettings.KEY_ICON_THEME_NAME);
        if (value != "")
            settings.set ("gtk-icon-theme-name", value, null);
        value = UGSettings.get_string (UGSettings.KEY_FONT_NAME);
        if (value != "")
            settings.set ("gtk-font-name", value, null);
        var double_value = UGSettings.get_double (UGSettings.KEY_XFT_DPI);
        if (double_value != 0.0)
            settings.set ("gtk-xft-dpi", (int) (1024 * double_value), null);
        var boolean_value = UGSettings.get_boolean (UGSettings.KEY_XFT_ANTIALIAS);
        settings.set ("gtk-xft-antialias", boolean_value, null);
        value = UGSettings.get_string (UGSettings.KEY_XFT_HINTSTYLE);
        if (value != "")
            settings.set ("gtk-xft-hintstyle", value, null);
        value = UGSettings.get_string (UGSettings.KEY_XFT_RGBA);
        if (value != "")
            settings.set ("gtk-xft-rgba", value, null);
*/
        debug("Creating greeter instance");
        var greeter = new DotfiveGreeter (true); // do_test_mode);

        debug ("Showing greeter");
        greeter.show ();

        // Handler so we quit cleanly
        GLib.Unix.signal_add(GLib.ProcessSignal.TERM, () => {
            debug("Got a SIGTERM");
            Gtk.main_quit();
            return true;
        });

        Gtk.main ();

        return Posix.EXIT_SUCCESS;
    }
}