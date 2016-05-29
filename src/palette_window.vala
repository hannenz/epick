using Gtk;
using Gdk;

namespace EPick {

	class PaletteWindow : Gtk.Window {

		protected TreeView tv;

		public Gtk.ListStore palette;

		public PaletteWindow () {

			Box vbox = new Box(Orientation.VERTICAL, 0);

			palette = new Gtk.ListStore(3, typeof(Gdk.Pixbuf), typeof(string), typeof(string));
			tv = new TreeView.with_model(palette);

			CellRendererPixbuf cr_pixbuf = new CellRendererPixbuf();
			TreeViewColumn col = new TreeViewColumn();
			col.set_title("Color");
			col.pack_start(cr_pixbuf, false);
			col.add_attribute(cr_pixbuf, "pixbuf", 0);
			tv.append_column(col);

			CellRendererText cr_text;
			cr_text = new CellRendererText();
			tv.insert_column_with_attributes(-1, "Code", cr_text, "text", 1);

			cr_text = new CellRendererText();
			tv.insert_column_with_attributes(-1, "Name", cr_text, "text", 2);

			vbox.add(tv);

			var close_button = new Button.with_label("Close");
			close_button.clicked.connect( () => {
					this.hide();
				});
			vbox.add(close_button);

			this.add(vbox);
		}
	}
}