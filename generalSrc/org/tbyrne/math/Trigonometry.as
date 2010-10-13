package org.tbyrne.math{
	import flash.geom.Point;
	
	public class Trigonometry{
		private static const RADIANS:Number = (Math.PI/180);
		
		public static function getDirection(fromPoint:Point, toPoint:Point):Number{
			var angle:Number = Math.atan2(-(fromPoint.x-toPoint.x), fromPoint.y-toPoint.y);
			return  angle*(180/Math.PI)
		}
		public static function getDistance(fromPoint:Point, toPoint:Point):Number{
			var difX:Number = (toPoint.x-fromPoint.x);
			var difY:Number = (toPoint.y-fromPoint.y);
			return Math.sqrt((difX*difX) + (difY*difY));
		}
		public static function getAngleTo(fromPoint:Point, toPoint:Point):Number{
			var ret:Number = (Math.atan2(fromPoint.y - toPoint.y, fromPoint.x - toPoint.x) * (180 / Math.PI))+90;
			ret -=180;
			ret = (ret<0)?ret+360:ret;
			return ret;
		}
		public static function getHypotonuse(side1:Number, side2:Number):Number{
			return getDistance(new Point(0,0),new Point(side1, side2));
		}
		public static function projectPoint(distance:Number, angle:Number, fromPoint:Point=null):Point{
			return new Point(projectX(distance, angle, fromPoint?fromPoint.x:0), projectY(distance, angle, fromPoint?fromPoint.y:0));
		}
		public static function projectX(distance:Number, angle:Number, fromX:Number):Number{
			return (distance*Math.cos((angle-90)*RADIANS))+fromX;
		}
		public static function projectY(distance:Number, angle:Number, fromY:Number):Number{
			return (distance*Math.sin((angle-90)*RADIANS))+fromY;
		}
	}
}