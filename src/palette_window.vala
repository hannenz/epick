using Gtk;
using Gdk;

namespace EPick {

	class PaletteWindow : Gtk.Window {

		protected TreeView tv;

		protected IconView iv;

		public Gtk.ListStore palette;

		public Gtk.Button pick_button;

		public PaletteWindow () {

			Box vbox = new Box(Orientation.VERTICAL, 0);
			var header_bar = new HeaderBar();
			var sw = new ScrolledWindow(null, null);
			var nb = new Notebook();

			pick_button = new Button.with_label("Pick");
			header_bar.set_title("epick");
			header_bar.set_show_close_button(true);
			header_bar.pack_start(pick_button);

			nb.append_page(sw, new Label("Default"));
			nb.set_show_tabs(false);

			set_titlebar(header_bar);
			set_default_size(120, 400);

			vbox.pack_start(header_bar);
			vbox.pack_start(nb);

			palette = new Gtk.ListStore(4, typeof(Gdk.Pixbuf), typeof(string), typeof(string), typeof(string));
			tv = new TreeView.with_model(palette);
			iv = new IconView.with_model(palette);
			iv.set_selection_mode(SelectionMode.BROWSE);
			iv.set_markup_column(3);
			iv.set_pixbuf_column(0);

			CellRendererPixbuf cr_pixbuf = new CellRendererPixbuf();
			TreeViewColumn col = new TreeViewColumn();
			col.set_title("Color");
			col.pack_start(cr_pixbuf, false);
			col.add_attribute(cr_pixbuf, "pixbuf", 0);
			tv.append_column(col);

			CellRendererText cr_text;
			// cr_text = new CellRendererText();
			// tv.insert_column_with_attributes(-1, "Code", cr_text, "text", 1);

			cr_text = new CellRendererText();
			//tv.insert_column_with_attributes(-1, "Name", cr_text, "text", 2);
			tv.insert_column_with_attributes(-1, "Name", cr_text, "markup", 3);

			sw.add(iv);

			var close_button = new Button.with_label("Close");
			close_button.clicked.connect( () => {
					this.hide();
				});
			vbox.add(close_button);

			this.add(vbox);
		}
	}
}