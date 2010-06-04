package au.com.thefarmdigital.display.views
{
	import flash.display.DisplayObject;
	
	public class SimpleContainer extends Container
	{
		override public function addChild(child:DisplayObject):DisplayObject{
			var result: DisplayObject = container.addChild(child);
			this.invalidateBothScrollMetrics();
			return result;
		}
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject{
			var result: DisplayObject = container.addChildAt(child, index);
			this.invalidateBothScrollMetrics();
			return result;
		}
		override public function removeChild(child:DisplayObject):DisplayObject{
			var result: DisplayObject = container.removeChild(child);
			this.invalidateBothScrollMetrics();
			return result;
		}
		override public function removeChildAt(index:int):DisplayObject{
			var result: DisplayObject = container.removeChildAt(index);
			this.invalidateBothScrollMetrics();
			return result;
		}
		override public function getChildAt(index:int):DisplayObject{
			return container.getChildAt(index);
		}
		override public function getChildByName(name:String):DisplayObject{
			return container.getChildByName(name);
		}
		override public function getChildIndex(child:DisplayObject):int{
			return container.getChildIndex(child);
		}
		override public function swapChildren(child1:DisplayObject, child2:DisplayObject):void{
			container.swapChildren(child1, child2);
		}
		override public function swapChildrenAt(index1:int, index2:int):void{
			container.swapChildrenAt(index1, index2);
		}
		override public function setChildIndex(child:DisplayObject, index:int):void{
			container.setChildIndex(child, index);
		}
		override public function contains(child:DisplayObject):Boolean{
			return container.contains(child);
		}
	}
}