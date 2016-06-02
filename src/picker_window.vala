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
using Cairo;

namespace Epick {

	class PickerWindow : Gtk.Window {


		protected Gdk.Window window;

		protected Gdk.Display display;

		protected DeviceManager manager;

		protected Gdk.Device mouse;

		protected Gtk.DrawingArea preview;

		protected int color_format;

		protected string color_string;

		protected Color current_color;

		protected Clipboard clipboard;


		// Constants 
		protected const int previewSize = 150;
		protected const double previewScale = 4;

		/**
		 * Constructor
		 *
		 * Build GUI
		 */
		public PickerWindow() {


			this.destroy.connect(main_quit);

			this.add_events(
				EventMask.KEY_PRESS_MASK |
				EventMask.BUTTON_PRESS_MASK
			);
			this.key_press_event.connect( (event_key) => {

				debug ("Key: %u".printf(event_key.keyval));

				switch (event_key.keyval){
					case 32:
						pick();
						break;

					default:
						close_picker ();
						break;

				}
				return false;
			});

			this.button_press_event.connect( () => {
				debug ("Button\n");
				return false;
			});

			preview = new Gtk.DrawingArea();
			preview.set_size_request(previewSize, previewSize);
			preview.draw.connect(on_draw);

			this.add(preview);

			window = Gdk.get_default_root_window();
			display = Display.get_default();
			manager = display.get_device_manager();
			mouse = manager.get_client_pointer();
			if (mouse == null) {
				error("Could not get device (mouse)");
			}

			window.set_events(EventMask.BUTTON_PRESS_MASK);

			clipboard = Gtk.Clipboard.get_for_display(display, Gdk.SELECTION_CLIPBOARD);

			Idle.add( () => {
				pick_color();
				return true;
			});

		}


		protected void close_picker () {
			// if (settings.get_boolean("grab-mouse-pointer")){
			// 	this.mouse.ungrab(Gdk.CURRENT_TIME);
			// }
			// if (settings.get_boolean("close-to-systray")){
				this.hide();
			// }
			// else {
			// 	Gtk.main_quit();
			// }
		}

		protected void open_picker () {
			var crosshair = new Gdk.Cursor.for_display(display, Gdk.CursorType.CROSSHAIR);
			// if (settings.get_boolean("grab-mouse-pointer")){
			// 	debug ("Grabbing mouse");
				this.mouse.grab(this.window, Gdk.GrabOwnership.APPLICATION, false, EventMask.ALL_EVENTS_MASK, crosshair, Gdk.CURRENT_TIME);
			// }
			this.show_all();
		}

		protected void add_to_palette() {

			uint32 _col = 
				(0xFF << 0) +
				((uint32)(current_color.blue  * 256) << 8) +
				((uint32)(current_color.green * 256) << 16) +
				((uint32)(current_color.red   * 256) << 24) +
				0
			;
			
			// bool is_doublette = false;
			// palette_window.palette.foreach( (model, path, iter) => {

			// 	uint32 _col2;

			// 	model.get(iter, 4, out _col2);
			// 	if (_col == _col2) {
			// 		is_doublette = true;
			// 		debug ("Won't add, since %s is already in palette", color_string);
			// 		return true; // stop iterating
			// 	}
			// 	return false; // continue
			// });

			// if (is_doublette) {
			// 	return;
			// }

			// Pixbuf pixbuf = new Pixbuf(Gdk.Colorspace.RGB, false, 8, 48, 48);
			// pixbuf.fill(_col);


			// TreeIter iter;
			// palette_window.palette.append(out iter);
			// palette_window.palette.set(
			// 	iter,
			// 	0, pixbuf,
			// 	1, color_string,
			// 	2, current_color.to_x11name(),
			// 	3, "<b>%s</b>\n<small>%s</small>".printf(current_color.to_x11name(), color_string),
			// 	4, _col
			// );

			// Gtk.Image image = new Gtk.Image.from_pixbuf(pixbuf);

			// Gtk.ImageMenuItem item = new Gtk.ImageMenuItem.with_label(color_string);
			// item.set_image(image);
			// item.activate.connect( () => {
			// 		clipboard.set_text(item.get_label(), -1);
			// 	});

//			menu.append(item);
			// menu.show_all();
		}


/*		protected void close() {
			mouse.ungrab(Gdk.CURRENT_TIME);
			this.hide();
		}
*/		
		protected void pick() {
			debug ("PICK");
			clipboard.set_text(color_string, -1);
			add_to_palette();
		}

		private bool on_draw(Context ctx) {
			int x, y;

			window.get_device_position(mouse, out x, out y, null);

			Pixbuf pixbuf = Gdk.pixbuf_get_from_window(this.window, x, y, 1, 1);
			weak uint8[] pixel = pixbuf.get_pixels();


			current_color.red = (double)pixel[0] / 256.0;
			current_color.green = (double)pixel[1] / 256.0;
			current_color.blue = (double)pixel[2] / 256.0;

			switch (color_format) {
				case 0:
					color_string = "#" + pixel[0].to_string("%02X") + pixel[1].to_string("%02X") + pixel[2].to_string("%02X");
					break;
				default:
					color_string = current_color.to_string();
					break;
			}

			Pixbuf _pixbuf = Gdk.pixbuf_get_from_window(window, x - (int)(previewSize / (2 * previewScale)), y - (int)(previewSize / (2* previewScale)), (int)(previewSize / previewScale), (int)(previewSize / previewScale));

			Pixbuf pixbuf2 = _pixbuf.scale_simple(previewSize, previewSize, InterpType.BILINEAR);

			Gdk.cairo_set_source_pixbuf(ctx, pixbuf2, 0, 0);
			ctx.paint();

			ctx.set_line_width(1);
			ctx.set_tolerance(0.1);
			ctx.set_source_rgb(1.0, 1.0, 1.0);
			ctx.arc(previewSize / 2, previewSize / 2, 3, 0, 2 * Math.PI);
			ctx.stroke();

			ctx.rectangle(0, 0, previewSize, previewSize);
			ctx.stroke();
			ctx.set_source_rgb(0, 0, 0);
			ctx.rectangle(1, 1, previewSize - 2, previewSize - 2);
			ctx.stroke();

			ctx.set_source_rgba(current_color.red, current_color.green, current_color.blue, 1.0);
			ctx.rectangle(2, previewSize - 24, previewSize - 4, 22);
			ctx.fill();

			/** 
			 * Calculate light/dark text color depending on the bg color
			 * Algorithm from: [http://stackoverflow.com/a/1855903]
			 */
			double d = 0.25;
			double a = 1 - ( 0.299 * pixel[0] + 0.587 * pixel[1] + 0.114 * pixel[2])/255;
			if (a >= 0.5) {
				d = 1.0;
			}
			ctx.set_source_rgb(d, d, d);
			ctx.select_font_face ("Sans", Cairo.FontSlant.NORMAL, Cairo.FontWeight.NORMAL);
			ctx.set_font_size (15.0);
			ctx.move_to (4, previewSize - 8);
			ctx.show_text (color_string);
			return false;
		}


		public void pick_color() {

			// Update the preview
			preview.queue_draw();

			// Move window (track mouse position)
			int x, y, posX, posY, offset = 10;

			window.get_device_position(mouse, out x, out y, null);
			posX = x + offset;
			posY = y + offset;

			if (posX + previewSize >= display.get_default_screen().get_width()) {
				posX = x - (offset + previewSize);
			}
			if (posY + previewSize >= display.get_default_screen().get_height()) {
				posY = y - (offset + previewSize);
			}

			this.move(posX, posY);

/*
			Gdk.Event event = display.get_event();
			if (event != null && event.type == EventType.BUTTON_PRESS){
				stdout.printf("click\n");
			}
*/
		}
	}
}
