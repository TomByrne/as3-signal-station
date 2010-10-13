package org.tbyrne.display.scrolling
{
	import org.tbyrne.display.actInfo.IMouseActInfo;
	import org.tbyrne.display.assets.assetTypes.IInteractiveObjectAsset;

	public class ScrollWheelScroller
	{
		public function get display():IInteractiveObjectAsset{
			return _display;
		}
		public function set display(value:IInteractiveObjectAsset):void{
			if(_display!=value){
				if(_display){
					_display.mouseWheel.removeHandler(onMouseWheel);
				}
				_display = value;
				if(_display){
					_display.mouseWheel.addHandler(onMouseWheel);
				}
			}
		}
		
		public var scrollMetrics:IScrollMetrics;
		
		private var _display:IInteractiveObjectAsset;
		
		public function ScrollWheelScroller(display:IInteractiveObjectAsset=null, scrollMetrics:IScrollMetrics=null){
			this.display = display;
			this.scrollMetrics = scrollMetrics;
		}
		protected function onMouseWheel(from:IInteractiveObjectAsset, mouseActInfo:IMouseActInfo, delta:int):void{
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