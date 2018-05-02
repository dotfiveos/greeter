public class GreeterWebView : WebKit.WebView {

    public static GreeterWebView instance;

    public GreeterWebView () {
        instance = this;

        debug("Hooking javascript window context");
        this.window_object_cleared.connect(addApp);

        debug("Setting web settings");
        WebKit.WebSettings web_settings = this.get_settings();

        web_settings.enable_plugins = true;
        web_settings.enable_scripts = true;
        web_settings.enable_universal_access_from_file_uris = true;
        web_settings.enable_file_access_from_file_uris = true;

        web_settings.auto_load_images = true;
        web_settings.default_font_family = "'sans-serif'";
        web_settings.default_font_size = 16;
        web_settings.javascript_can_access_clipboard = true;
        web_settings.user_agent = "DotFive Login Greeter (https://github.com/dotfiveos/greeter)";

        debug("Getting theme name and url");
        string theme_name = DotfiveGreeter.instance.config.get_string("greeter", "theme");
        debug("Using theme %s", theme_name);
        string theme_url = "file://" + Config.THEME_DIR + "/" + theme_name + "/index.html";
        debug("Theme URL %s", theme_url);

        debug("Connecting to LightDM signals");
        DotfiveGreeter.instance.show_message.connect((text, type) => {
            string stype = "";
            if(type == LightDM.MessageType.ERROR) {
                stype = "error";
            } else if (type == LightDM.MessageType.INFO) {
                stype = "info";
            }
            instance.execute_script("show_message('%s', '%s')".printf (text, stype));
        });

        DotfiveGreeter.instance.show_prompt.connect((text, type) => {
            string stype = "";
            if(type == LightDM.PromptType.SECRET) {
                stype = "secret";
            } else if (type == LightDM.PromptType.QUESTION) {
                stype = "question";
            }
            instance.execute_script("show_prompt('%s', '%s')".printf (text, stype));
        });

        DotfiveGreeter.instance.authentication_complete.connect(() => {
            instance.execute_script("authentication_complete()");
        });

        DotfiveGreeter.instance.autologin_timer_expired.connect(() => {
            instance.execute_script("autologin_timer_expired()");
        });

        debug("Loading theme uri");
        this.load_uri(theme_url);
    }

    public static JSCore.Value authenticate_cb(JSCore.Context ctx, JSCore.Object function, JSCore.Object thisObject, JSCore.Value[] arguments, out JSCore.Value exception) {
        exception = null;

        if(arguments.length > 0) {
            JSCore.String JSCore_string = arguments[0].to_string_copy(ctx, null);

            size_t max_size = JSCore_string.get_maximum_utf8_c_string_size();
            char *c_string = new char[max_size];
            JSCore_string.get_utf8_c_string(c_string, max_size);

            debug("authenticating as: %s\n", (string) c_string);

            DotfiveGreeter.instance.authenticate((string) c_string);
        } else {
            DotfiveGreeter.instance.authenticate();
        }

        // return new JSCore.Value.string(ctx, new JSCore.String.with_utf8_c_string(data));
        return new JSCore.Value.null(ctx);
    }

    public static JSCore.Value get_default_session_hint (JSCore.Context ctx, JSCore.Object thisObject, JSCore.String propertyName, out JSCore.Value exception) {
        return new JSCore.Value.string(ctx, new JSCore.String.with_utf8_c_string(DotfiveGreeter.instance.default_session_hint()));
    }

    /* static const JSCore.StaticValue[] lightdm_values = {
        {"default_session_hint", get_default_session_hint, null, JSCore.PropertyAttribute.ReadOnly}
    }; */

    static const JSCore.StaticValue[] lightdm_values = {};

    static const JSCore.StaticFunction[] lightdm_functions = {
        {"authenticate", authenticate_cb, JSCore.PropertyAttribute.ReadOnly}
    };

    static const JSCore.ClassDefinition lightdm_definition = {
        0,
        JSCore.ClassAttribute.None,
        "LightDM",
        null,
        lightdm_values,
        lightdm_functions
    };

    // passes data to javascript via having the javascript call a function
    public void addApp(WebKit.WebFrame frame, void *context, void *window_object) {
        debug("Adding objects to webkit context");
        unowned JSCore.Context ctx = (JSCore.Context) context;
        JSCore.Object global = ctx.get_global_object();
        
        JSCore.Value ex;

        debug("Creating js class from definition");
        JSCore.Class lightdm_class = new JSCore.Class(lightdm_definition);
        debug("Creating object from class");
        JSCore.Object lightdm_object = new JSCore.Object(ctx, lightdm_class, ctx);
        debug("Injecting object into context");
        global.set_property(
            ctx,
            new JSCore.String.with_utf8_c_string("lightdm"),
            lightdm_object,
            JSCore.PropertyAttribute.None,
            out ex );
    }
}