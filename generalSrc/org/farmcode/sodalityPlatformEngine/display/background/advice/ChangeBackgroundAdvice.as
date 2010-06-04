package org.farmcode.sodalityPlatformEngine.display.background.advice
{
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodalityPlatformEngine.display.background.adviceTypes.IChangeBackgroundAdvice;
	
	import flash.display.DisplayObject;

	public class ChangeBackgroundAdvice extends Advice implements IChangeBackgroundAdvice
	{
		[Property(toString="true",clonable="true")]
		public function get background():DisplayObject{
			return _background;
		}
		public function set background(value:DisplayObject):void{
			_background = value;
		}
		
		private var _background:DisplayObject;
		
		public function ChangeBackgroundAdvice()
		{
			super();
		}
	}
}