using Gtk;
using Gdk;

namespace Epick {

	class PaletteWindow : Gtk.ApplicationWindow {


		public Gtk.ToolButton toggle_view_button;

		private Gtk.Notebook notebook;


		public signal void new_palette_button_clicked();


		public PaletteWindow (Gtk.Application app) {

			GLib.Object(application: app, type: Gtk.WindowType.TOPLEVEL);


			this.delete_event.connect(() => {
					this.application.activate_action("app.quit", null);
					return false;
				});

			Box vbox = new Box(Orientation.VERTICAL, 0);

			var header_bar = new HeaderBar();

			var pick_button = new ToolButton(
				new Gtk.Image.from_icon_name("color-select-symbolic", IconSize.SMALL_TOOLBAR),
				_("Pick")
			);
			pick_button.clicked.connect( () => {

					var epick = application as Epick;
					epick.pick();

				});

			Gtk.ToolButton btn;

			btn = new Gtk.ToolButton(null, null);
			btn.set_icon_name("document-new");
			btn.clicked.connect( () => {
					new_palette_button_clicked();
				});
			header_bar.pack_end(btn);

			Gtk.Image icon;
			var _app = this.application as Epick;
			switch (_app.settings.get_string("view-mode")) {
				case "Grid":
					icon = new Gtk.Image.from_icon_name("view-list-symbolic", IconSize.SMALL_TOOLBAR);
					break;
				case "List":
				default:
					icon = new Gtk.Image.from_icon_name("view-grid-symbolic", IconSize.SMALL_TOOLBAR);
					break;
			}
			toggle_view_button = new Gtk.ToolButton(icon, null);
			toggle_view_button.clicked.connect(toggle_view_mode);
			header_bar.pack_end(toggle_view_button);
			// btn = new Gtk.ToolButton(new Gtk.Image.from_icon_name("view-list-symbolic", IconSize.SMALL_TOOLBAR), null);
			// header_bar.pack_end(btn);


			header_bar.set_title("Color Picker");
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
				_app.current_palette = index;
			});

			notebook.page_removed.connect( (page, index) => {

				debug ("Removing page %u".printf(index));

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

			var sw = new ScrolledWindow(null, null);

			var _app = this.application as Epick;
			var view_mode = _app.settings.get_string("view-mode");
			switch (view_mode) {

				case "Grid":
					var iv = create_icon_view();
					iv.set_model(palette.list_store);
					sw.add(iv);
					break;
				case "List":
				default:
					var tv = create_tree_view();
					tv.set_model(palette.list_store);
					sw.add(tv);
					break;
			}

			sw.show_all();

			//notebook.append_page(sw, new Label(palette.name));

			// Label with close button
			var label = new Label(palette.name);

			var img = new Image.from_icon_name("window-close", Gtk.IconSize.MENU);

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

		/**
		 * Remove the current page from the notebook
		 */
		public void remove_palette() {

			notebook.remove_page(notebook.get_current_page());

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


			tv.row_activated.connect( (tv, path, column) => {
					debug ("The row has been activated");


					var popover = new ActionPopover(tv);

					// Get the cell area
					Rectangle rect;
					tv.get_cell_area(path, column, out rect);
					popover.set_pointing_to(rect);

					popover.show_all();

					var menu = new GLib.Menu();
					menu.append("Copy to clipboard", "copy-clipboard");
					popover.bind_model(menu, "app");

					// Actions for context menu (popover)
					GLib.SimpleAction copy_clipboard = new GLib.SimpleAction("copy-clipboard", null);
					var _app = this.application as Epick;
					_app.add_action(copy_clipboard);
					copy_clipboard.activate.connect(() => {
						print ("Copy to clipboard has been activated\n");
						// Get the current palette (from _app)
					});

				});


			return tv;			
		}


		private IconView create_icon_view() {

			/* Create the IconView */
			IconView iv = new IconView();
			iv.set_selection_mode(SelectionMode.BROWSE);
			iv.set_reorderable(true);
			iv.set_pixbuf_column(Palette.PaletteColumn.PIXBUF_COLUMN);
			iv.set_markup_column(Palette.PaletteColumn.MARKUP_COLUMN);


			iv.item_activated.connect( (path) => {

				var popover = new ActionPopover(iv);

				// Get the cell area
				Rectangle rect;
				iv.get_cell_rect(path, null, out rect);
				popover.set_pointing_to(rect);

				popover.show_all();
			});




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
		protected void toggle_view_mode() {
			var _app = this.application as Epick;
			var view_mode = _app.settings.get_string("view-mode");
			switch (view_mode) {
				case "List":
					switch_to_grid();
					_app.settings.set_string("view-mode", "Grid");
					toggle_view_button.set_icon_name("view-list-symbolic");
					toggle_view_button.set_icon_widget(null);
					// toggle_view_button.set_icon_widget(new Gtk.Image.from_icon_name("view-grid-symbolic", IconSize.SMALL_TOOLBAR));

					break;
				case "Grid":
					switch_to_list();
					_app.settings.set_string("view-mode", "List");
					toggle_view_button.set_icon_name("view-grid-symbolic");
					toggle_view_button.set_icon_widget(null);
					break;

			}
		}
	}

}
