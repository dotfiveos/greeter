using Gtk;
using WebKit;
using Soup;

public class Monitor {
    public int x;
    public int y;
    public int width;
    public int height;

    public Monitor (int x, int y, int width, int height) {
        this.x = x;
        this.y = y;
        this.width = width;
        this.height = height;
    }

    public bool equals (Monitor? other) {
        if (other != null)
            return (x == other.x && y == other.y && width == other.width && height == other.height);

        return false;
    }
}

public class MainWindow : Gtk.Window {

    private List<Monitor> monitors;
    private Monitor? primary_monitor;
    private Monitor active_monitor;
    private int window_size_x;
    private int window_size_y;
    private bool do_resize;

    private WebView web_view;

    construct {
        events |= Gdk.EventMask.POINTER_MOTION_MASK;

        var accel_group = new Gtk.AccelGroup ();
        add_accel_group (accel_group);

        var bg_color = Gdk.RGBA ();
        // bg_color.parse (UGSettings.get_string (UGSettings.KEY_BACKGROUND_COLOR));
        bg_color.parse("#0066FF");
        override_background_color (Gtk.StateFlags.NORMAL, bg_color);
        get_accessible ().set_name (_("Login Screen"));
        has_resize_grip = false;

        this.get_style_context().add_class("lightdm");

        // UserStyleSheet global_styles = new WebKit.UserStyleSheet("", UserContentInjectedFrames.TOP_FRAME, UserStyleLevel.USER, null, null);

        // UserContentManager content_manager = new WebKit.UserContentManager();
        // content_manager.add_style_sheet(global_styles);

        // web_view = new WebKit.WebView.with_user_content_manager(content_manager);
        web_view = new WebView();
        // WebView();

        web_view.window_object_cleared.connect(addApp);

        // var web_settings = new WebKit.Settings();
        WebSettings web_settings = web_view.get_settings();

        web_settings.enable_plugins = true;
        web_settings.enable_scripts = true;
        web_settings.enable_universal_access_from_file_uris = true;
        web_settings.enable_file_access_from_file_uris = true;

        web_settings.auto_load_images = true;
        web_settings.default_font_family = "'sans-serif'";
        web_settings.default_font_size = 16;
        web_settings.javascript_can_access_clipboard = true;
        web_settings.user_agent = "DotFive Login Greeter (https://github.com/dotfiveos/greeter)";

        string theme_name = DotfiveGreeter.instance.config.get_string("greeter", "theme");
        debug("Using theme %s", theme_name);
        string theme_url = "file://" + Config.THEME_DIR + "/" + theme_name + "/index.html";
        debug("Theme URL %s", theme_url);

        web_view.load_uri(theme_url);
        this.add(web_view); 

        this.show_all();

        window_size_x = 0;
        window_size_y = 0;
        primary_monitor = null;
        do_resize = false;

        /*if (SlickGreeter.singleton.test_mode)
            {
                // Simulate an 800x600 monitor to the left of a 640x480 monitor
                monitors = new List<Monitor> ();
                monitors.append (new Monitor (0, 0, 800, 600));
                monitors.append (new Monitor (800, 120, 640, 480));
                background.set_monitors (monitors);
                move_to_monitor (monitors.nth_data (0));
                resize (800 + 640, 600);
            }
            else
            {
                var screen = get_screen ();
                screen.monitors_changed.connect (monitors_changed_cb);
                monitors_changed_cb (screen);
            } */

        var screen = get_screen ();
        screen.monitors_changed.connect (monitors_changed_cb);
        monitors_changed_cb (screen);
        setup_window(); // required otherwise it waits for another change before resizing
    }

    public static JSCore.Value getData(JSCore.Context ctx,
                                   JSCore.Object function,
                                   JSCore.Object thisObject,
                                   JSCore.Value[] arguments,
                                   out JSCore.Value exception) {
        exception = null;

        return new JSCore.Value.string(ctx, new JSCore.String.with_utf8_c_string("test string!"));

        /* lock (data) {
            return new JSCore.Value.string(ctx, new JSCore.String.with_utf8_c_string(data));
        } */
    }

    // called by javascript
    public static JSCore.Value exit(JSCore.Context ctx,
                                JSCore.Object function,
                                JSCore.Object thisObject,
                                JSCore.Value[] arguments,
                                out JSCore.Value exception) {
        exception = null;

        JSCore.String JSCore_string = arguments[0].to_string_copy(ctx, null);

        size_t max_size = JSCore_string.get_maximum_utf8_c_string_size();
        char *c_string = new char[max_size];
        JSCore_string.get_utf8_c_string(c_string, max_size);

        stdout.printf("%s\n", (string) c_string);

        Gtk.main_quit();

        return new JSCore.Value.null(ctx);
    }

    // passes data to javascript via having the javascript call a function
    public void addApp(WebFrame frame, void *context, void *window_object) {
        unowned JSCore.Context ctx = (JSCore.Context) context;
        JSCore.Object global = ctx.get_global_object();
        
        JSCore.String name = new JSCore.String.with_utf8_c_string("app_getData");
        JSCore.Value ex;
                            
        global.set_property(ctx,
                            name,
                            new JSCore.Object.function_with_callback(ctx, name, getData),
                            JSCore.PropertyAttribute.ReadOnly,
                            out ex);

        name = new JSCore.String.with_utf8_c_string("app_exit");
        
        global.set_property(ctx,
                            name,
                            new JSCore.Object.function_with_callback(ctx, name, exit),
                            JSCore.PropertyAttribute.ReadOnly,
                            out ex);
    }

    /**
     * Original Function Copyright (C) 2011 Canonical Ltd 
     * Modified Function Copyright (C) 2018 Keith Mitchell 
    */
    public void setup_window () {
        resize (window_size_x, window_size_y);
        move (0, 0);
        move_to_monitor (primary_monitor);
    }

    /**
     * Original Function Copyright (C) 2011 Canonical Ltd 
     * Modified Function Copyright (C) 2018 Keith Mitchell 
    */
    private void monitors_changed_cb (Gdk.Screen screen) {
        Gdk.Display display = screen.get_display();
        Gdk.Monitor primary = display.get_primary_monitor();
        Gdk.Rectangle geometry;

        window_size_x = 0;
        window_size_y = 0;
        monitors = new List<Monitor> ();
        primary_monitor = null;

        for (var i = 0; i < display.get_n_monitors (); i++) {
            Gdk.Monitor monitor = display.get_monitor(i);
            geometry = monitor.get_geometry ();
            debug ("Monitor %d is %dx%d pixels at %d,%d", i, geometry.width, geometry.height, geometry.x, geometry.y);

            if (window_size_x < geometry.x + geometry.width) {
                window_size_x = geometry.x + geometry.width;
            }

            if (window_size_y < geometry.y + geometry.height) {
                window_size_y = geometry.y + geometry.height;
            }

            if (monitor_is_unique_position (display, i)) {
                var greeter_monitor = new Monitor (geometry.x, geometry.y, geometry.width, geometry.height);
                monitors.append (greeter_monitor);

                if (primary_monitor == null || primary == monitor)
                    primary_monitor = greeter_monitor;
            }
        }

        debug ("MainWindow is %dx%d pixels", window_size_x, window_size_y);

        // background.set_monitors (monitors);

        if(do_resize) {
            setup_window ();
        } else {
            do_resize = true;
        }
    }

    /**
     * Original Function Copyright (C) 2011 Canonical Ltd 
     * Modified Function Copyright (C) 2018 Keith Mitchell 
    */
    private bool monitor_is_unique_position (Gdk.Display display, int n) {
        Gdk.Rectangle g0;
        Gdk.Monitor mon0;
        mon0 = display.get_monitor(n);
        g0 = mon0.get_geometry ();

        for (var i = n + 1; i < display.get_n_monitors (); i++) {
            Gdk.Rectangle g1;
            Gdk.Monitor mon1;
            mon1 = display.get_monitor(i);
            g1 = mon1.get_geometry();

            if (g0.x == g1.x && g0.y == g1.y)
                return false;
        }

        return true;
    }

    /**
     * Original Function Copyright (C) 2011 Canonical Ltd 
     * Modified Function Copyright (C) 2018 Keith Mitchell 
    */
    public override bool motion_notify_event (Gdk.EventMotion event) {
        var x = (int) (event.x + 0.5);
        var y = (int) (event.y + 0.5);

        /* Get motion event relative to this widget */
        if (event.window != get_window ()) {
            int w_x, w_y;
            get_window ().get_origin (out w_x, out w_y);
            x -= w_x;
            y -= w_y;
            event.window.get_origin (out w_x, out w_y);
            x += w_x;
            y += w_y;
        }

        foreach (var m in monitors) {
            if (x >= m.x && x <= m.x + m.width && y >= m.y && y <= m.y + m.height) {
                move_to_monitor (m);
                break;
            }
        }

        return false;
    }

    private void move_to_monitor (Monitor monitor) {
        active_monitor = monitor;
        //login_box.set_size_request (monitor.width, monitor.height);
        //background.set_active_monitor (monitor);
        //background.move (login_box, monitor.x, monitor.y);

        web_view.set_size_request(monitor.width, monitor.height);
        web_view.show_all();

        //if (shutdown_dialog != null) {
        //    shutdown_dialog.set_active_monitor (monitor);
            //background.move (shutdown_dialog, monitor.x, monitor.y);
        //}
    }

}