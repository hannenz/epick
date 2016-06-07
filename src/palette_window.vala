using Gtk;
using Gdk;

namespace Epick {

	class PaletteWindow : Gtk.ApplicationWindow {


		public Gtk.Button pick_button;

		private Gtk.Notebook notebook;





		public PaletteWindow (Gtk.Application app) {

			GLib.Object(application: app, type: Gtk.WindowType.TOPLEVEL);


			this.delete_event.connect(() => {
					this.application.activate_action("app.quit", null);
					return false;
				});

			Box vbox = new Box(Orientation.VERTICAL, 0);

			var header_bar = new HeaderBar();

			pick_button = new Button.with_label("Pick");
			pick_button.clicked.connect( () => {

					var epick = application as Epick;
					epick.pick();

				});
			header_bar.set_title("epick");
			header_bar.set_show_close_button(true);
			header_bar.pack_start(pick_button);


			notebook = new Notebook();
			notebook.page_added.connect(() => {
				notebook.set_show_tabs(notebook.get_n_pages() > 1);
			});
			notebook.page_removed.connect(() => {
				notebook.set_show_tabs(notebook.get_n_pages() > 1);
			});

			notebook.popup_enable();

			notebook.switch_page.connect( (page, index) => {
				var _app = this.application as Epick;
				_app.current_palette = index;
			});

			notebook.page_removed.connect( (page, index) => {

				debug ("Removing page %u".printf(index));

				var _app = this.application as Epick;
				debug ("We have %u palettes at the moment", _app.palettes.length());

				Palette palette = _app.palettes.nth_data(index);

				palette.save();

				_app.palettes.remove(palette);

			});



			set_titlebar(header_bar);
			set_default_size(120, 600);

			vbox.pack_start(header_bar);
			vbox.pack_start(notebook);

			this.add(vbox);
			this.show_all();
		}

		public void add_palette(Palette palette) {
			
			var tv = create_tree_view();
			tv.set_model(palette.list_store);

			var sw = new ScrolledWindow(null, null);
			sw.add(tv);
			sw.show_all();

			//notebook.append_page(sw, new Label(palette.name));

			// Label with close button
			var label = new Label(palette.name);

			var img = new Image.from_icon_name(Gtk.Stock.CLOSE, Gtk.IconSize.MENU);

			var hbox = new Box(Gtk.Orientation.HORIZONTAL, 0);

			var button = new Button();
			button.set_relief(Gtk.ReliefStyle.NONE);
			button.set_focus_on_click(false);
			button.add(img);

			var style = new Gtk.RcStyle();
			style.xthickness = 0;
			style.ythickness = 0;
			button.modify_style(style);

			hbox.pack_start(button);
			hbox.pack_start(label);

			hbox.show_all();

			int p;
			if ((p = notebook.append_page(sw, hbox)) != -1) {
				notebook.set_current_page(p);
			}

			button.clicked.connect( () => {
					notebook.remove_page(notebook.page_num(sw));
				});
		}


		private TreeView create_tree_view() {

			/* Create the TreeView */
			TreeView tv = new TreeView();
			CellRendererPixbuf cr_pixbuf = new CellRendererPixbuf();
			TreeViewColumn col = new TreeViewColumn();
			col.set_title("Color");
			col.pack_start(cr_pixbuf, false);
			col.add_attribute(cr_pixbuf, "pixbuf", Palette.PaletteColumn.PIXBUF_COLUMN);
			tv.rules_hint = true;
			tv.set_reorderable(true);
			tv.append_column(col);

			var cr_text = new CellRendererText();
			tv.insert_column_with_attributes(-1, "Name", cr_text, "markup", Palette.PaletteColumn.MARKUP_COLUMN);

			return tv;			
		}


		private IconView create_icon_view() {

			/* Create the IconView */
			IconView iv = new IconView();
			iv.set_selection_mode(SelectionMode.BROWSE);
			iv.set_reorderable(true);
			iv.set_pixbuf_column(Palette.PaletteColumn.PIXBUF_COLUMN);
			iv.set_markup_column(Palette.PaletteColumn.MARKUP_COLUMN);

			return iv;
		}


		public void switch_to_grid() {

			notebook.foreach( (page) => {

					var sw = page as ScrolledWindow;

					TreeView tv = sw.get_child() as TreeView;

					IconView iv = create_icon_view();
					iv.set_model(tv.get_model());

					sw.remove(tv);
					sw.add(iv);

					iv.show();
				});

		}

		public void switch_to_list() {

			notebook.foreach( (page) => {
					var sw = page as ScrolledWindow;

					IconView iv = sw.get_child() as IconView;

					TreeView tv = create_tree_view();
					tv.set_model(iv.get_model());

					sw.remove(iv);
					sw.add(tv);

					tv.show();
				});
		}
	}
}