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

		protected Gdk.Device keyboard;

		protected Gtk.DrawingArea preview;

		protected int color_format;

		protected string color_string;

		protected Color current_color;

		protected Clipboard clipboard;

		protected Epick app;

		// Constants 
		protected const int previewSize = 150;
		protected const double previewScale = 4;

		/**
		 * Constructor
		 */
		public PickerWindow(Epick app) {
			Object(type: Gtk.WindowType.POPUP);

			this.app = app;

			this.skip_pager_hint = true;
			this.skip_taskbar_hint = true;
			this.decorated = false;

			this.add_events(
				EventMask.KEY_PRESS_MASK |
				EventMask.BUTTON_PRESS_MASK
			);
			this.key_press_event.connect( (event_key) => {

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
			keyboard = mouse.get_associated_device();
			if (keyboard == null) {
				error("Could not get device (keyboard)");
			}

			clipboard = Gtk.Clipboard.get_for_display(display, Gdk.SELECTION_CLIPBOARD);

			this.button_press_event.connect( (event) => {
				pick();
				return false;
			});

			Idle.add( () => {
				pick_color();
				return true;
			});
			
			this.show_all();
		}




		public void open_picker () {
			var crosshair = new Gdk.Cursor.for_display(display, Gdk.CursorType.CROSSHAIR);
			// if (settings.get_boolean("grab-mouse-pointer")){
				var status = this.mouse.grab(this.get_window(), Gdk.GrabOwnership.APPLICATION, false, EventMask.BUTTON_PRESS_MASK | EventMask.BUTTON_RELEASE_MASK | EventMask.POINTER_MOTION_MASK, crosshair, Gdk.CURRENT_TIME);
				this.keyboard.grab(this.get_window(), Gdk.GrabOwnership.APPLICATION, false, EventMask.KEY_PRESS_MASK, null, Gdk.CURRENT_TIME); 
			// }

			this.show_all();
		}




		protected void close_picker () {
			// if (settings.get_boolean("grab-mouse-pointer")){
				this.mouse.ungrab(Gdk.CURRENT_TIME);
				this.keyboard.ungrab(Gdk.CURRENT_TIME);
			// }
			// if (settings.get_boolean("close-to-systray")){
				this.hide();
			// }
			// else {
			// 	Gtk.main_quit();
			// }
		}

		protected void pick() {

			clipboard.set_text(color_string, -1);

			unowned List<Palette> elem = this.app.palettes.nth(this.app.current_palette);
			Palette palette = elem.data;
			palette.add_color(current_color);

			// TODO: Make customizable // setting
			close_picker();
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
			int x, y, posX, posY, offset = 50;

			window.get_device_position(mouse, out x, out y, null);
			posX = x + offset;
			posY = y + offset;

			if (posX + previewSize >= display.get_default_screen().get_width()) {
				posX = x - (offset + previewSize);
			}
			if (posY + previewSize >= display.get_default_screen().get_height()) {
				posY = y - (offset + previewSize);
			}

			move(posX, posY);
		}
	}
}
