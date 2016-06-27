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

		// private PickerWindow picker_window;

		private SettingsDialog settings_dialog;

		public List<Palette> palettes;

		public uint current_palette;

		// protected AppIndicator.Indicator indicator;

		// protected Gtk.Menu menu;



		public Epick() {

			debug ("Starting Application");

			application_id = "de.hannenz.epick";


		}






		public override void activate() {

			debug ("activate");

			palette_window = new PaletteWindow(this);

			palette_window.new_palette_button_clicked.connect( () => {
					debug ("The »New palette« Button has been clicked, cowboy!");
					this.activate_action("new_palette", null);
				});

			settings = new GLib.Settings("de.hannenz.epick");

			settings.changed["view-mode"].connect(set_view_mode);
			set_view_mode();

			settings_dialog = new SettingsDialog(settings);

			palette_window.present();

			load_palettes();
		}





		public override void startup() {

			base.startup();

			debug ("startup");

			string ui =	"""
		 		<interface>
			 		<menu id='appmenu'>
			 			<section>
			 				<item>
			 					<attribute name='label' translatable='yes'>_New palette</attribute>
			 					<attribute name='action'>app.new_palette</attribute>
			 				</item>
			 			</section>
					    <section>
					      <item>
					        <attribute name='label' translatable='yes'>_Preferences</attribute>
					        <attribute name='action'>app.preferences</attribute>
					      </item>
					    </section>
					    <section>
					      <item>
					        <attribute name='label' translatable='yes'>_Quit</attribute>
					        <attribute name='action'>app.quit</attribute>
					      </item>
					    </section>
					  </menu>
					</interface>
		 	""";

			var action = new GLib.SimpleAction("new_palette", null);
			action.activate.connect(new_palette);
			add_accelerator("<Ctrl>N", "app.new_palette", null);
			add_action(action);

			action = new GLib.SimpleAction("preferences", null);
			action.activate.connect(preferences);
			add_action(action);

			action = new GLib.SimpleAction("quit", null);
			action.activate.connect(quit);
			add_action(action);
			add_accelerator("<Ctrl>Q", "app.quit", null);

			action = new GLib.SimpleAction("pick", null);
			action.activate.connect(pick);
			add_accelerator("<Ctrl>P", "app.pick", null);
			add_action(action);

			action = new GLib.SimpleAction("close_palette", null);
			action.activate.connect(close_palette);
			add_accelerator("<Ctrl>W", "app.close_palette", null);
			add_action(action);

		 	var builder = new Gtk.Builder.from_string(ui, -1);
		 	var menu = builder.get_object("appmenu") as GLib.MenuModel;
			set_app_menu(menu);
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




		public void pick() {

			var picker_window = new PickerWindow(this);
			picker_window.present();
			picker_window.open_picker();

		}


		protected void preferences() {

			debug ("Preferences");

			var settings_dialog = new SettingsDialog(settings);
			settings_dialog.show_all();
			settings_dialog.run();
		}


		protected void new_palette() {

			var box = new Box(Orientation.VERTICAL, 0);
			var entry = new Entry();
			entry.set_activates_default(true);
			box.pack_start(new Label("Name"));
			box.pack_start(entry);

			var dlg = new Gtk.Dialog.with_buttons(
				"New palette",
				null,
				Gtk.DialogFlags.MODAL,
				"Cancel", Gtk.ResponseType.CANCEL,
				"OK", Gtk.ResponseType.OK,
				null
			);
			var content_area = dlg.get_content_area();
			content_area.add(box);

			dlg.set_default_response(ResponseType.OK);

			dlg.show_all();

			if (dlg.run() == Gtk.ResponseType.OK) {

				string name = entry.get_text();
				if (name.length > 0) {
					Palette palette = new Palette(entry.get_text(), null);
					palettes.append(palette);
					palette_window.add_palette(palette);
				}
			}

			dlg.destroy();
		}


		protected void close_palette() {
			palette_window.remove_palette();
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
				if (!FileUtils.test(palettes_dir, FileTest.EXISTS)) {

					debug (".palettes dir (%s) does not exist, creating it now.".printf(palettes_dir));
					dir.make_directory();

				}
				var enumerator = dir.enumerate_children(FileAttribute.STANDARD_NAME, 0);

				FileInfo file_info;
				int n = 0;
				while ((file_info = enumerator.next_file()) != null) {

					string file_path = GLib.Path.build_path("/", palettes_dir, file_info.get_name());

					debug ("Loading palette: %s".printf(file_path));

					var palette = new Palette(file_info.get_name(), file_path);
					if (palette.load()) {

						palettes.append(palette);

						palette_window.add_palette(palette);
						n++;
					}
				}

				if (n == 0) {
					var palette = new Palette("Default", null);
					palettes.append(palette);
					palette_window.add_palette(palette);
				}
			}
			catch (Error e) {
				error ("Error: " + e.message);
			}
		}





		static int main(string[] args){
			Gtk.init(ref args);
			var app = new Epick();

			return app.run();

 		}
	}
}
