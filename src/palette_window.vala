using Gtk;
using Gdk;

namespace Epick {

	class PaletteWindow : Gtk.ApplicationWindow {

		protected TreeView tv;

		protected IconView iv;

		protected ScrolledWindow sw;

		public Gtk.ListStore palette;

		public Gtk.Button pick_button;




		public PaletteWindow (Gtk.Application app) {

			GLib.Object(application: app);



			Box vbox = new Box(Orientation.VERTICAL, 0);
			sw = new ScrolledWindow(null, null);

			var header_bar = new HeaderBar();

			pick_button = new Button.with_label("Pick");
			header_bar.set_title("epick");
			header_bar.set_show_close_button(true);
			header_bar.pack_start(pick_button);


			var nb = new Notebook();
			nb.page_added.connect(() => {
				nb.set_show_tabs(nb.get_n_pages() > 1);
			});
			nb.page_removed.connect(() => {
				nb.set_show_tabs(nb.get_n_pages() > 1);
			});

			nb.append_page(sw, new Label("Default"));

			set_titlebar(header_bar);
			set_default_size(120, 600);

			vbox.pack_start(header_bar);
			vbox.pack_start(nb);

			palette = new Gtk.ListStore(
				5,
				typeof(Gdk.Pixbuf), /* The color swatch */
				typeof(string), 	/* The color as string (accoring to settings, HEX or RGB) */
				typeof(string),		/* The color's X11 name */
				typeof(string),		/* Markup */
				typeof(int)			/* Color as 32bit Integer */
			);

			/* Create the IconView */
			iv = new IconView.with_model(palette);
			iv.set_selection_mode(SelectionMode.BROWSE);
			iv.set_reorderable(true);
			iv.set_pixbuf_column(0);
			iv.set_markup_column(3);

			/* Create the TreeView */
			tv = new TreeView.with_model(palette);
			CellRendererPixbuf cr_pixbuf = new CellRendererPixbuf();
			TreeViewColumn col = new TreeViewColumn();
			col.set_title("Color");
			col.pack_start(cr_pixbuf, false);
			col.add_attribute(cr_pixbuf, "pixbuf", 0);
			tv.rules_hint = true;
			tv.set_reorderable(true);
			tv.append_column(col);

			var cr_text = new CellRendererText();
			tv.insert_column_with_attributes(-1, "Name", cr_text, "markup", 3);

			this.add(vbox);
			this.show_all();
		}

		public void switch_to_grid() {

			sw.remove(sw.get_child());
			sw.add(iv);
			iv.show();
			tv.hide();
		}

		public void switch_to_list() {

			sw.remove(sw.get_child());
			sw.add(tv);
			tv.show();
			iv.hide();
		}
	}
}