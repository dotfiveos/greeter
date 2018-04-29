using WebKit;

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

        web_view = new WebView();
        web_view.load_uri("https://google.com/");
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