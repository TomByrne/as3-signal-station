package org.tbyrne.math{
	import flash.geom.Point;
	
	public class Trigonometry{
		private static const RADIANS:Number = (Math.PI/180);
		
		public static function getDirection(fromX:Number, fromY:Number, toX:Number, toY:Number):Number{
			var angle:Number = Math.atan2(-(fromX-toX), fromY-toY);
			return  angle*(180/Math.PI)
		}
		public static function getDistance(fromX:Number, fromY:Number, toX:Number, toY:Number):Number{
			var difX:Number = (toX-fromX);
			var difY:Number = (toY-fromY);
			return Math.sqrt((difX*difX) + (difY*difY));
		}
		public static function getAngleTo(fromX:Number, fromY:Number, toX:Number, toY:Number):Number{
			var ret:Number = (Math.atan2(fromY - toY, fromX - toX) * (180 / Math.PI))+90;
			ret -=180;
			ret = (ret<0)?ret+360:ret;
			return ret;
		}
		public static function getHypotonuse(side1:Number, side2:Number):Number{
			return getDistance(0,0,side1,side2);
		}
		public static function projectPoint(distance:Number, angle:Number, fromX:Number=0, fromY:Number=0):Point{
			return new Point(projectX(distance, angle, fromX), projectY(distance, angle, fromY));
		}
		public static function projectX(distance:Number, angle:Number, fromX:Number):Number{
			return (distance*Math.cos((angle-90)*RADIANS))+fromX;
		}
		public static function projectY(distance:Number, angle:Number, fromY:Number):Number{
			return (distance*Math.sin((angle-90)*RADIANS))+fromY;
		}
	}
}