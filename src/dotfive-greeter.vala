using GLib;
using Gtk;
using Cairo;

public class DotfiveGreeter {
    
    public static DotfiveGreeter instance;

    public bool testmode = false;

    public signal void show_message (string text, LightDM.MessageType type);
    public signal void show_prompt (string text, LightDM.PromptType type);
    public signal void autologin_timer_expired ();
    public signal void authentication_complete ();
    // public signal void starting_session ();

    private Cairo.XlibSurface background_surface;
    private MainWindow main_window;

    private LightDM.Greeter greeter;

    private static Timer log_timer;

    public KeyFile config;

    private DotfiveGreeter (bool _testmode) {
        instance = this;
        testmode = _testmode;

        debug("Loading config file");
        config = new KeyFile ();
        config.set_list_separator (',');
        config.load_from_file("/etc/lightdm/lightdm-dotfive-greeter.conf", KeyFileFlags.NONE);

        debug ("Creating background surface");
        background_surface = create_root_surface (Gdk.Screen.get_default ());

        debug ("Creating lightdm greeter instance");
        greeter = new LightDM.Greeter ();
        
        greeter.show_message.connect ((text, type) => {
            show_message (text, type);
            debug("Show message called %s", text);
        });
        
        greeter.show_prompt.connect ((text, type) => {
            show_prompt (text, type);
            debug("Show prompt called %s", text);
        });
        
        greeter.autologin_timer_expired.connect (() => {
            autologin_timer_expired();
            // greeter.authenticate_autologin ();
            debug("autologin time expired");
        });
        
        greeter.authentication_complete.connect (() => {
            authentication_complete ();
            debug("authentication complete");
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
    }

    public void authenticate (string? userid = null) {
        greeter.authenticate (userid);
    } 

    /**
     * Original Function Copyright (C) 2011 Canonical Ltd 
     * Modified Function Copyright (C) 2018 Keith Mitchell 
    */
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
    
    /**
     * Original Function Copyright (C) 2011 Canonical Ltd 
     * Modified Function Copyright (C) 2018 Keith Mitchell 
    */
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

        debug("Creating greeter instance");
        var greeter = new DotfiveGreeter (true);

        debug ("Showing greeter");

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