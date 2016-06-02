/**
 * ePick
 *
 * A color picker tool for elementaryOS
 * inspired by [gpick](https://code.google.com/p/gpick/) - but simpler ;)
 *
 * @author Johannes Braun <me@hannenz.de>
 * 2014-04
 *
 * TODO: Implement color class
 * 		internal: RGB as Integer
 * 		methods to in- and output from/ to "hex", "rgb(r,g,b)", RGBA32 RGBA 8-bit, XColorName
 * 		Maybe extend Gdk.RGBA
 */
using Gtk;
using Gdk;
using AppIndicator;

namespace Epick {

	class Epick : Gtk.Application {









		public GLib.Settings settings;

		private PaletteWindow palette_window;

		private PickerWindow picker_window;

		private SettingsDialog settings_dialog;

		private List<Palette> palettes;

		// protected AppIndicator.Indicator indicator;

		// protected Gtk.Menu menu;



		public Epick() {

			debug ("Starting Application");

			application_id = "de.hannenz.epick";


		}






		public override void activate() {

			debug ("activate");

			palette_window = new PaletteWindow(this);

			settings = new GLib.Settings("de.hannenz.epick");

			settings.changed["view-mode"].connect(set_view_mode);
			set_view_mode();

			picker_window = new PickerWindow();

			settings_dialog = new SettingsDialog(settings);

			palette_window.present();

			load_palettes();
		}





		/**
		 * Set the palette window's view mode (list or grid)
		 * according to the current settings
		 */
		protected void set_view_mode() {
			string view_mode = settings.get_string("view-mode");
			if (view_mode == "List") {
				palette_window.switch_to_list();
			}
			else if (view_mode == "Grid") {
				palette_window.switch_to_grid();
			}
		}






		// protected void build_indicator() {

		// 	indicator = new Indicator("epick", "", IndicatorCategory.APPLICATION_STATUS);
		// 	indicator.set_icon("/usr/share/icons/hicolor/128x218/apps/epick.png");
		// 	indicator.set_status(IndicatorStatus.ACTIVE);

		// 	menu = new Gtk.Menu();

		// 	Gtk.MenuItem item;

		// 	item = new Gtk.MenuItem.with_label("Pick color");
		// 	item.activate.connect(open_picker);
		// 	menu.append(item);

		// 	item = new Gtk.MenuItem.with_label("Settings");
		// 	item.activate.connect( () => {
		// 			settings_dialog.show_all();
		// 		});
		// 	menu.append(item);

		// 	item = new Gtk.MenuItem.with_label("Palette");
		// 	item.activate.connect( () => {
		// 			palette_window.show_all();
		// 		});
		// 	menu.append(item);

		// 	item = new Gtk.MenuItem.with_label("Exit");
		// 	item.activate.connect(quit);
		// 	menu.append(item);
		// 	menu.show_all();

		// 	indicator.set_menu(menu);
		// }





		// protected void quit() {
		// 	Gtk.main_quit();
		// }













		public void load_palettes() {

			string palettes_dir = GLib.Path.build_path("/", Environment.get_home_dir(), ".palettes");

			try {
				var dir = File.new_for_path(palettes_dir);
				var enumerator = dir.enumerate_children(FileAttribute.STANDARD_NAME, 0);

				FileInfo file_info;
				while ((file_info = enumerator.next_file()) != null) {

					string file_path = GLib.Path.build_path("/", palettes_dir, file_info.get_name());

					debug ("Loading palette: %s".printf(file_path));

					palettes.append(new Palette(file_info.get_name(), file_path));

				}
			}
			catch (Error e) {
				error ("Error: " + e.message);
			}
		}





		static int main(string[] args){
			Gtk.init(ref args);
			var app = new Epick();

			// if (!app.settings.get_boolean("start-in-systray")){
			// 	app.picker_window.open_picker();
			// }

			app.run();


			Gtk.main();
			return 0;
 		}
	}
}
