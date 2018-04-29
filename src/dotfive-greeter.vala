public class DotfiveGreeter {
    
    public static DotfiveGreeter instance;

    public bool testmode = false;

    public signal void show_message (string text, LightDM.MessageType type);
    public signal void show_prompt (string text, LightDM.PromptType type);
    public signal void authentication_complete ();
    public signal void starting_session ();

    private LightDM.Greeter greeter;

    private static Timer log_timer;

    private DotfiveGreeter (bool _testmode) {
        instance = this;
        testmode = _testmode;

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

        return Posix.EXIT_SUCCESS;
    }
}