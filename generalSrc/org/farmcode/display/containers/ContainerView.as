package org.farmcode.display.containers
{
	
	import flash.display.DisplayObject;
	
	import org.farmcode.display.assets.IAsset;
	import org.farmcode.display.assets.IDisplayAsset;
	import org.farmcode.display.core.LayoutView;
	
	public class ContainerView extends LayoutView
	{
		private static const BACKING_ASSET:String = "backing";
		
		protected var _backing:IDisplayAsset;
		
		public function ContainerView(asset:IDisplayAsset=null){
			super(asset);
		}
		override protected function bindToAsset() : void{
			if(_containerAsset){
				_backing = _containerAsset.takeAssetByName(BACKING_ASSET,IAsset,true);
			}
		}
		override protected function unbindFromAsset() : void{
			if(_containerAsset && _backing){
				_containerAsset.returnAsset(_backing);
				_backing = null;
			}
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
	}
}