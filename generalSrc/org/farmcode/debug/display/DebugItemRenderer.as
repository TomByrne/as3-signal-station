package org.farmcode.debug.display
{
	import org.farmcode.data.dataTypes.IBitmapProvider;
	import org.farmcode.display.assets.AssetNames;
	import org.farmcode.display.assets.assetTypes.IBitmapAsset;
	import org.farmcode.display.assets.assetTypes.IDisplayAsset;
	import org.farmcode.display.controls.TextLabelButton;
	
	public class DebugItemRenderer extends TextLabelButton
	{
		override public function set data(value:*):void{
			if(data != value){
				if(_bitmapProvider){
					_bitmapProvider.bitmapDataChanged.removeHandler(onBitmapChanged);
					if(_bitmap)_bitmap.bitmapData = null;
				}
				super.data = value;
				_bitmapProvider = (value as IBitmapProvider);
				if(_bitmapProvider){
					_bitmapProvider.bitmapDataChanged.addHandler(onBitmapChanged);
					if(_bitmap)_bitmap.bitmapData = _bitmapProvider.bitmapData;
					dispatchMeasurementChange();
				}
			}
		}
		
		private var _bitmap:IBitmapAsset;
		private var _bitmapProvider:IBitmapProvider;
		
		private var _bitmapPaddingTop:Number;
		private var _bitmapPaddingBottom:Number;
		private var _bitmapPaddingLeft:Number;
		private var _bitmapPaddingRight:Number;
		
		public function DebugItemRenderer(asset:IDisplayAsset=null){
			super(asset);
		}
		override protected function init() : void{
			super.init();
			padding = 3;
			togglable = true;
		}
		protected function onBitmapChanged(from:IBitmapProvider) : void{
			if(_bitmap)_bitmap.bitmapData = _bitmapProvider.bitmapData;
			dispatchMeasurementChange();
		}
		override protected function bindToAsset() : void{
			super.bindToAsset();
			_bitmap = _containerAsset.takeAssetByName(AssetNames.DEBUG_ITEM_BITMAP,IBitmapAsset);
			_bitmapPaddingTop = _bitmap.y;
			_bitmapPaddingLeft = _bitmap.x;
			_bitmapPaddingRight = _backing.naturalWidth-(_bitmap.x+_bitmap.naturalWidth);
			_bitmapPaddingBottom = _backing.naturalHeight-(_bitmap.y+_bitmap.naturalHeight);
			if(_bitmapProvider)_bitmap.bitmapData = _bitmapProvider.bitmapData;
			dispatchMeasurementChange();
		}
		override protected function unbindFromAsset() : void{
			super.unbindFromAsset();
			_containerAsset.returnAsset(_bitmap);
			_bitmap.bitmapData = null;
			_bitmap = null;
		}
		override protected function measure() : void{
			super.measure();
			if(_bitmap && _bitmap.bitmapData){
				var bitH:Number = _bitmap.bitmapData.height+_bitmapPaddingTop+_bitmapPaddingBottom;
				var bitW:Number = _bitmap.bitmapData.width+_bitmapPaddingLeft+_bitmapPaddingRight;
				if(_measurements.x<bitW){
					_measurements.x = bitW;
				}
				if(_measurements.y<bitH){
					_measurements.y = bitH;
				}
			}
		}
		override protected function draw() : void{
			super.draw();
		}
	}
}