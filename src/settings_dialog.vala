using Gtk;

namespace EPick {

	class SettingsDialog : Gtk.Dialog {

		protected GLib.Settings settings;

		protected CheckButton start_in_systray_cb;
		protected CheckButton close_to_systray_cb;
		protected CheckButton grab_mouse_pointer_cb;
		protected ComboBoxText color_format_cb;

		public SettingsDialog (GLib.Settings settings) {

			this.settings = settings;
			this.response.connect(on_response);

			Box content =  this.get_content_area() as Gtk.Box;

			start_in_systray_cb = new CheckButton.with_label("Start in systray");
			start_in_systray_cb.set_active(settings.get_boolean("start-in-systray"));
			start_in_systray_cb.toggled.connect( () => {
					settings.set_boolean("start-in-systray", start_in_systray_cb.get_active());
				});
			content.pack_start(start_in_systray_cb, false, true, 0);

			close_to_systray_cb = new CheckButton.with_label("Close to systray");
			close_to_systray_cb.set_active(settings.get_boolean("close-to-systray"));
			close_to_systray_cb.toggled.connect( () => {
					settings.set_boolean("close-to-systray", close_to_systray_cb.get_active());
				});
			content.pack_start(close_to_systray_cb, false, true, 0);

			grab_mouse_pointer_cb = new CheckButton.with_label("Grab mousepointer");
			grab_mouse_pointer_cb.set_active(settings.get_boolean("grab-mouse-pointer"));
			grab_mouse_pointer_cb.toggled.connect( () => {
					settings.set_boolean("grab-mouse-pointer", grab_mouse_pointer_cb.get_active());
				});
			content.pack_start(grab_mouse_pointer_cb, false, true, 0);

			color_format_cb = new ComboBoxText();
			color_format_cb.append_text("hex");
			color_format_cb.append_text("rgb");

			color_format_cb.active = settings.get_string("color-format") == "hex" ? 0 : 1;
			color_format_cb.changed.connect( () => {
					settings.set_string("color-format", color_format_cb.get_active_text());
				});
			content.pack_start(color_format_cb, false, false, 0);

			add_button("_Close", Gtk.ResponseType.CLOSE);
		}

		protected void on_response(Gtk.Dialog dlg, int response_id) {
			switch (response_id) {
				case Gtk.ResponseType.CLOSE:
					hide();
					break;
			}

		}
	}
}