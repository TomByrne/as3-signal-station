package org.farmcode.display.behaviour.containers
{
	
	import flash.display.DisplayObject;
	
	import org.farmcode.display.behaviour.LayoutViewBehaviour;
	
	public class ContainerView extends LayoutViewBehaviour
	{
		protected var _backing:DisplayObject;
		
		public function ContainerView(asset:DisplayObject=null){
			super(asset);
		}
		override protected function bindToAsset() : void{
			if(containerAsset){
				_backing = containerAsset.getChildByName("backing");
			}
		}
		override protected function unbindFromAsset() : void{
			_backing = null;
		}
		override protected function draw() : void{
			positionAsset();
			positionBacking();
		}
		protected function positionBacking():void{
			if(_backing){
				_backing.width = displayPosition.width;
				_backing.height = displayPosition.height;
			}
		}
		protected function positionAsset():void{
			asset.x = displayPosition.x;
			asset.y = displayPosition.y;
		}
	}
}