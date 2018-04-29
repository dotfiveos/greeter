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
  }
}