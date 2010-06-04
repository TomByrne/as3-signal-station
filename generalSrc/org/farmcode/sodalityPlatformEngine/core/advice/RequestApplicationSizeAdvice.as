package org.farmcode.sodalityPlatformEngine.core.advice
{
	import org.farmcode.sodalityPlatformEngine.core.adviceTypes.IRequestApplicationSizeAdvice;
	
	import flash.geom.Rectangle;
	
	import org.farmcode.sodality.advice.Advice;

	public class RequestApplicationSizeAdvice extends Advice implements IRequestApplicationSizeAdvice
	{
		public function set appBounds(value:Rectangle):void{
			_appBounds = value;
		}
		public function get appBounds():Rectangle{
			return _appBounds;
		}
		public function set appScale(value:Number):void{
			_appScale = value;
		}
		public function get appScale():Number{
			return _appScale;
		}
		
		private var _appScale:Number;
		private var _appBounds:Rectangle;
		
	}
}