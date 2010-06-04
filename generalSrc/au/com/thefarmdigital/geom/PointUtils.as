package au.com.thefarmdigital.geom
{
	import flash.geom.Point;
	
	public class PointUtils
	{
		public static function equals(pt1: Point, pt2: Point): Boolean
		{
			var equal: Boolean = (pt1 == pt2);
			if (!equal && pt1 != null && pt2 != null)
			{
				equal = pt1.equals(pt2);
			}
			return equal;
		}
	}
}