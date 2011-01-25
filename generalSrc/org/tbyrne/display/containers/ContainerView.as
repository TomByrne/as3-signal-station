package org.tbyrne.display.containers
{
	
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	
	import org.tbyrne.display.assets.AssetNames;
	import org.tbyrne.display.assets.assetTypes.IAsset;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
	import org.tbyrne.display.core.LayoutView;
	
	public class ContainerView extends LayoutView
	{
		protected var _backing:IDisplayObject;
		
		public function ContainerView(asset:IDisplayObject=null){
			super(asset);
		}
		override protected function bindToAsset() : void{
			super.bindToAsset();
			if(_containerAsset){
				_backing = _containerAsset.takeAssetByName(AssetNames.BACKING,IAsset,true);
				if(_backing)_backing.setPosition(0,0);
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
		override protected function commitSize():void{
			positionBacking(size.x,size.y);
		}
		protected function positionBacking(width:Number, height:Number):void{
			if(_backing){
				_backing.setSize(width,height);
			}
		}
	}
}