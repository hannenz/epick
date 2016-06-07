using Gdk;
using Gtk;

namespace Epick {


	/**
	* @class Palette
	* Handles one palette of colors, loading and saving from / to disk,
	* storage in a Gtk.ListStore
	*/
	
	class Palette {

		public enum PaletteColumn {
			PIXBUF_COLUMN,
			HASH_COLUMN,
			HEX_STRING_COLUMN,
			RGB_STRING_COLUMN,
			X11_NAME_COLUMN,
			RED_COLUMN,
			GREEN_COLUMN,
			BLUE_COLUMN,
			MARKUP_COLUMN,
			N_COLUMNS
		}


		public string name;

		public Gtk.ListStore list_store;

		protected File file;




		public Palette(string name, string? filename) {

			this.name = name;

			this.list_store = new Gtk.ListStore(
				PaletteColumn.N_COLUMNS,
				typeof(Pixbuf),
				typeof(uint),
				typeof(string),
				typeof(string),
				typeof(string),
				typeof(double),
				typeof(double),
				typeof(double),
				typeof(string)
			);
			
			if (filename != null) {
				this.file = File.new_for_path(filename);
				load ();
			}
			else {
				int n = 0;
				do {
					filename = (n == 0) ? name : "%s %u".printf(name, n);
					this.file = File.new_for_path(GLib.Path.build_path("/", Environment.get_home_dir(), ".palettes", filename));
					n++;
				}
				while (file.query_exists());
			}

		}




		public void add_color(Color color) {

			TreeIter iter;
			list_store.append(out iter);
			list_store.set(
				iter,
				PaletteColumn.PIXBUF_COLUMN, color.get_pixbuf(),
				PaletteColumn.HASH_COLUMN, color.hash(),
				PaletteColumn.HEX_STRING_COLUMN, color.to_string(),
				PaletteColumn.RGB_STRING_COLUMN, color.to_string(),
				PaletteColumn.X11_NAME_COLUMN, color.to_x11name(),
				PaletteColumn.RED_COLUMN, color.red,
				PaletteColumn.GREEN_COLUMN, color.green,
				PaletteColumn.BLUE_COLUMN, color.blue,
				PaletteColumn.MARKUP_COLUMN, "<b>%s</b>\n<small>%s</small>".printf(color.to_x11name(), color.to_string())
			);

		}



		public void remove_color(Color color) {
			uint hash = color.hash();

			list_store.foreach( (model, path, iter) => {

				uint _hash;
				model.get(iter, PaletteColumn.HASH_COLUMN, out _hash);
				if (_hash == hash) {
					return true;
				}
				return false;

			});
		}





		public bool load() {

			try {
				var dis = new DataInputStream(file.read());
				string line;

				while ((line = dis.read_line(null)) != null) {
					var color = Color();

					if (color.parse(line)) {
						add_color(color);
					}
				}
			}
			catch (Error e) {
				warning ("Error: " + e.message);
				return false;
			}
			return true;
		}

		public bool save() {

			debug ("Saving to file: " + file.get_parse_name());

			try {

				if (file.query_exists()) {
					file.delete();
				}
				var dos = new DataOutputStream(file.create(FileCreateFlags.REPLACE_DESTINATION));

				list_store.foreach( (model, path, iter) => {
					double red, green, blue;
					model.get(iter,
						Palette.PaletteColumn.RED_COLUMN, out red,
						Palette.PaletteColumn.GREEN_COLUMN, out green,
						Palette.PaletteColumn.BLUE_COLUMN, out blue,
						-1
					);
					var color = new Color();
					color.red = red;
					color.green = green;
					color.blue = blue;

					dos.put_string(color.to_string() + "\n");

					return false;
				});
			}
			catch (Error e) {
				warning ("Error: " + e.message);
				return false;
			}



			return true;

		}



	}
}