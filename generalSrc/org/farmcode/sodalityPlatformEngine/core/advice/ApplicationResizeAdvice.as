package org.farmcode.sodalityPlatformEngine.core.advice
{
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodalityPlatformEngine.core.adviceTypes.IApplicationResizeAdvice;
	
	import flash.geom.Rectangle;

	public class ApplicationResizeAdvice extends Advice implements IApplicationResizeAdvice
	{
		[Property(toString="true",clonable="true")]
		public function get appBounds():Rectangle{
			return _appBounds;
		}
		public function set appBounds(value:Rectangle):void{
			_appBounds = value;
		}
		
		[Property(toString="true",clonable="true")]
		public function get appScale():Number{
			return _appScale;
		}
		public function set appScale(value:Number):void{
			_appScale = value;
		}
		
		private var _appScale:Number = 1;
		private var _appBounds:Rectangle;
		
		public function ApplicationResizeAdvice(appBounds:Rectangle=null, appScale:Number=1){
			super(true);
			this.appBounds = appBounds;
			this.appScale = appScale;
		}
		
	}
}