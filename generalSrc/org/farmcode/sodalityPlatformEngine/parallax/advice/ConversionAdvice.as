package org.farmcode.sodalityPlatformEngine.parallax.advice
{
	import au.com.thefarmdigital.parallax.Point3D;
	import org.farmcode.sodality.advice.Advice;
	
	import flash.geom.Point;

	public class ConversionAdvice extends Advice
	{
		[Property(toString="true",clonable="true")]
		public function get screenPoint():Point{
			return _screenPoint;
		}
		public function set screenPoint(value:Point):void{
			_screenPoint = value;
		}
		[Property(toString="true",clonable="true")]
		public function get screenDepth():Number{
			return _screenDepth;
		}
		public function set screenDepth(value:Number):void{
			_screenDepth = value;
		}
		[Property(toString="true",clonable="true")]
		public function get parallaxPoint():Point3D{
			return _parallaxPoint;
		}
		public function set parallaxPoint(value:Point3D):void{
			_parallaxPoint = value;
		}
		
		private var _screenPoint:Point;
		private var _screenDepth:Number;
		private var _parallaxPoint:Point3D;
		
		public function ConversionAdvice(){
			super(true);
		}
	}
}