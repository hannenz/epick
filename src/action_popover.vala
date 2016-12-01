using Gtk;

namespace Epick {

	public class ActionPopover : Gtk.Popover {
		

		public ActionPopover(Widget widget) {

			this.set_relative_to(widget);
			this.set_position(PositionType.RIGHT);




			var box2 = new Box(Orientation.VERTICAL, 5);

			box2.add(new Label("Lorem ipsum"));
			box2.add(new Label("Dolor sit amet"));

			this.add(box2);
		}

	}
}
