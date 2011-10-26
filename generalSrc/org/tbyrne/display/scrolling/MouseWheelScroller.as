package org.tbyrne.display.scrolling
{
	import org.tbyrne.actInfo.IMouseActInfo;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObjectContainer;
	import org.tbyrne.display.assets.nativeTypes.IInteractiveObject;
	import org.tbyrne.display.assets.utils.isDescendant;

	public class MouseWheelScroller
	{
		
		protected static var instances:Vector.<MouseWheelScroller> = new Vector.<MouseWheelScroller>();
		
		protected static function shouldCapture(from:MouseWheelScroller, mouseTarget:IDisplayObject):Boolean{
			if(from.interactiveObject==mouseTarget)return true;
			
			var cast:IDisplayObjectContainer = (from.interactiveObject as IDisplayObjectContainer);
			if(cast){
				for each(var instance:MouseWheelScroller in instances){
					if(instance!=from){
						var scrollMetrics:IScrollMetrics = instance.scrollMetrics;
						if(scrollMetrics.pageSize<scrollMetrics.maximum-scrollMetrics.minimum){
							var otherInt:IInteractiveObject = instance.interactiveObject;
							var otherCast:IDisplayObjectContainer = (otherInt as IDisplayObjectContainer);
							if(isDescendant(cast,otherInt) && (otherInt==mouseTarget || (otherCast && isDescendant(otherCast,mouseTarget)))){
								return false;
							}
						}
					}
				}
			}
			return true;
		}
		
		public function get interactiveObject():IInteractiveObject{
			return _interactiveObject;
		}
		public function set interactiveObject(value:IInteractiveObject):void{
			if(_interactiveObject!=value){
				if(_interactiveObject){
					_interactiveObject.mouseWheel.removeHandler(onMouseWheel);
					_interactiveObject.addedToStage.removeHandler(onAddedToStage);
					_interactiveObject.removedFromStage.removeHandler(onRemovedFromStage);
					if(_added){
						onRemovedFromStage();
					}
				}
				_interactiveObject = value;
				if(_interactiveObject){
					_interactiveObject.mouseWheel.addHandler(onMouseWheel);
					_interactiveObject.addedToStage.addHandler(onAddedToStage);
					_interactiveObject.removedFromStage.addHandler(onRemovedFromStage);
					if(_interactiveObject.stage){
						onAddedToStage();
					}
				}
			}
		}
		
		public var scrollMetrics:IScrollMetrics;
		private var _added:Boolean;
		
		private var _interactiveObject:IInteractiveObject;
		
		public function MouseWheelScroller(interactiveObject:IInteractiveObject=null, scrollMetrics:IScrollMetrics=null){
			this.interactiveObject = interactiveObject;
			this.scrollMetrics = scrollMetrics;
		}
		protected function onMouseWheel(from:IInteractiveObject, mouseActInfo:IMouseActInfo, delta:int):void{
			if(scrollMetrics && shouldCapture(this,mouseActInfo.mouseTarget)){
				// delta values vary great by browser/wmode, I prefer to use this mechanism, this means there will be no native acceleration.
				delta = (delta>0?1:-1);
				
				var newValue:Number = scrollMetrics.scrollValue-delta;
				if(newValue<scrollMetrics.minimum)newValue = scrollMetrics.minimum;
				if(newValue>scrollMetrics.maximum-scrollMetrics.pageSize)newValue = scrollMetrics.maximum-scrollMetrics.pageSize;
				scrollMetrics.scrollValue = newValue;
			}
		}
		private function onAddedToStage(from:IInteractiveObject=null):void{
			instances.push(this);
		}
		private function onRemovedFromStage(from:IInteractiveObject=null):void{
			var index:int = instances.indexOf(this);
			instances.splice(index,1);
		}
	}
}