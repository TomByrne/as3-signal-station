package org.farmcode.display.scrolling
{
	import org.farmcode.display.actInfo.IMouseActInfo;
	import org.farmcode.display.assets.assetTypes.IInteractiveObjectAsset;

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
		public var multiplier:Number=1;
		
		private var _display:IInteractiveObjectAsset;
		
		public function ScrollWheelScroller(display:IInteractiveObjectAsset=null, scrollMetrics:IScrollMetrics=null){
			this.display = display;
			this.scrollMetrics = scrollMetrics;
		}
		protected function onMouseWheel(from:IInteractiveObjectAsset, mouseActInfo:IMouseActInfo, delta:int):void{
			if(scrollMetrics){
				var newValue:Number = scrollMetrics.scrollValue-delta*multiplier;
				if(newValue<scrollMetrics.minimum)newValue = scrollMetrics.minimum;
				if(newValue>scrollMetrics.maximum)newValue = scrollMetrics.maximum;
				scrollMetrics.scrollValue = newValue;
			}
		}
	}
}