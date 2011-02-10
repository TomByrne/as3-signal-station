package org.tbyrne.display.scrolling
{
	import org.tbyrne.display.actInfo.IMouseActInfo;
	import org.tbyrne.display.assets.nativeTypes.IInteractiveObject;

	public class MouseWheelScroller
	{
		public function get interactiveObject():IInteractiveObject{
			return _interactiveObject;
		}
		public function set interactiveObject(value:IInteractiveObject):void{
			if(_interactiveObject!=value){
				if(_interactiveObject){
					_interactiveObject.mouseWheel.removeHandler(onMouseWheel);
				}
				_interactiveObject = value;
				if(_interactiveObject){
					_interactiveObject.mouseWheel.addHandler(onMouseWheel);
				}
			}
		}
		
		public var scrollMetrics:IScrollMetrics;
		
		private var _interactiveObject:IInteractiveObject;
		
		public function MouseWheelScroller(interactiveObject:IInteractiveObject=null, scrollMetrics:IScrollMetrics=null){
			this.interactiveObject = interactiveObject;
			this.scrollMetrics = scrollMetrics;
		}
		protected function onMouseWheel(from:IInteractiveObject, mouseActInfo:IMouseActInfo, delta:int):void{
			if(scrollMetrics){
				// delta values vary great by browser/wmode, I prefer to use this mechanism, this means there will be no native acceleration.
				delta = (delta>0?1:-1);
				
				var newValue:Number = scrollMetrics.scrollValue-delta;
				if(newValue<scrollMetrics.minimum)newValue = scrollMetrics.minimum;
				if(newValue>scrollMetrics.maximum-scrollMetrics.pageSize)newValue = scrollMetrics.maximum-scrollMetrics.pageSize;
				scrollMetrics.scrollValue = newValue;
			}
		}
	}
}