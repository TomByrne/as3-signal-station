package org.farmcode.display.containers
{
	
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	
	import org.farmcode.display.assets.AssetNames;
	import org.farmcode.display.assets.assetTypes.IAsset;
	import org.farmcode.display.assets.assetTypes.IDisplayAsset;
	import org.farmcode.display.core.LayoutView;
	
	public class ContainerView extends LayoutView
	{
		protected var _backing:IDisplayAsset;
		
		public function ContainerView(asset:IDisplayAsset=null){
			super(asset);
		}
		override protected function bindToAsset() : void{
			super.bindToAsset();
			if(_containerAsset){
				_backing = _containerAsset.takeAssetByName(AssetNames.BACKING,IAsset,true);
			}
		}
		override protected function unbindFromAsset() : void{
			if(_containerAsset && _backing){
				_containerAsset.returnAsset(_backing);
				_backing = null;
			}
			super.unbindFromAsset();
		}
		override protected function measure():void{
			checkIsBound();
			if(_backing){
				_measurements.x = _backing.naturalWidth;
				_measurements.y = _backing.naturalHeight;
			}else{
				super.measure();
			}
		}
		override protected function draw() : void{
			positionAsset();
			positionBacking(0,0,displayPosition.width,displayPosition.height);
		}
		protected function positionBacking(x:Number, y:Number, width:Number, height:Number):void{
			if(_backing){
				_backing.setSizeAndPos(x,y,width,height);
			}
		}
	}
}