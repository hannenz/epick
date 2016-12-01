using Gtk;

namespace Epick {

	public class ActionPopover : Gtk.Popover {
		

		public ActionPopover(Widget widget) {

			this.set_relative_to(widget);
			this.set_position(PositionType.RIGHT);
		}

	}
}
