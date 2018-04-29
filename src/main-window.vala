using WebKit;

public class MainWindow : Gtk.Window {

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

    /* Gtk.ColorButton button = new Gtk.ColorButton ();

		// Use alpha channel
		button.set_use_alpha (true);

		// Set value to blue:
		Gdk.RGBA rgba = Gdk.RGBA ();
		bool tmp = rgba.parse ("#0066FF");
		assert (tmp == true);

		button.rgba = rgba;

		// Sets the title for the color selection dialog:
		button.set_title ("Select your favourite color");

		// Catch color-changes:
		button.color_set.connect (() => {
			uint16 alpha = button.get_alpha ();
			stdout.printf ("%s, %hu\n", button.rgba.to_string (), alpha);
		});
    this.add (button);*/

    var view = new WebView();
    view.load_uri("https://google.com/");
    this.add(view); 
    
    this.show_all();
  }
}