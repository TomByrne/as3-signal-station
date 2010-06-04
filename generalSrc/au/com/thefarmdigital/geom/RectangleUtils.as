package au.com.thefarmdigital.geom
{
	import flash.geom.Rectangle;
	
	public class RectangleUtils
	{
		public static function equals(rect1: Rectangle, rect2: Rectangle): Boolean
		{
			var equal: Boolean = (rect1 == rect2);
			if (!equal && rect1 != null && rect2 != null)
			{
				equal = rect1.equals(rect2);
			}
			return equal;
		}
	}
}