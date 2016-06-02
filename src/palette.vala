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
			N_COLUMNS
		}


		protected string name;

		protected File file;

		protected Gtk.ListStore list_store;



		public Palette(string name, string filename) {

			this.name = name;

			this.file = File.new_for_path(filename);

			this.list_store = new Gtk.ListStore(
				PaletteColumn.N_COLUMNS,
				typeof(Pixbuf),
				typeof(uint),
				typeof(string),
				typeof(string),
				typeof(string),
				typeof(double),
				typeof(double),
				typeof(double)
			);

			load ();
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
				PaletteColumn.BLUE_COLUMN, color.blue
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

			return true;

		}



	}
}