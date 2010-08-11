package org.farmcode.display.containers
{
	
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	
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
			super.bindToAsset();
			if(_containerAsset){
				_backing = _containerAsset.takeAssetByName(BACKING_ASSET,IAsset,true);
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
				if(!_displayMeasurements){
					_displayMeasurements = new Rectangle();
					_displayMeasurements.x = 0;
					_displayMeasurements.y = 0;
					_displayMeasurements.width = _backing.naturalWidth;
					_displayMeasurements.height = _backing.naturalHeight;
				}
			}else{
				super.measure();
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