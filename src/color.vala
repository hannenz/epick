using Gdk;

namespace Epick {

	public class Color  {

		public enum SpecType {
			HEX3,
			HEX6,
			RGB,
			RGBA
		}

		protected Gdk.Color color;

		public Color.from_string (string spec){
			Gdk.Color color;
			this.parse(spec, out color);
			this.color = color;
		}

		public bool parse (string spec, out Gdk.Color color) {

			try {

				MatchInfo match_info;
				var regex = new Regex("^#([0-9a-f]{6}|[0-9a-f]{3})$");

				if (regex.match(spec, 0, out match_info)){

				}
			}
			catch (Error e) {
				error ("%s\n", e.message);
			}
			return true;
		}

		public string to_string(SpecType spec_type) {
			return "foo";
		}
	}
}