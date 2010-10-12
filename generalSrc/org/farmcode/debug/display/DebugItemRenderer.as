package org.farmcode.debug.display
{
	import flash.events.Event;
	import flash.geom.Point;
	
	import org.farmcode.data.dataTypes.IBitmapDataProvider;
	import org.farmcode.debug.data.coreTypes.ILayoutViewProvider;
	import org.farmcode.display.assets.AssetNames;
	import org.farmcode.display.assets.assetTypes.IBitmapAsset;
	import org.farmcode.display.assets.assetTypes.IDisplayAsset;
	import org.farmcode.display.controls.TextLabelButton;
	import org.farmcode.display.core.ILayoutView;
	
	public class DebugItemRenderer extends TextLabelButton
	{
		override public function set data(value:*):void{
			if(data != value){
				if(_bitmapDataProvider){
					_bitmapDataProvider.bitmapDataChanged.removeHandler(onBitmapChanged);
				}
				if(_layoutViewProvider){
					_layoutViewProvider.layoutViewChanged.removeHandler(onViewChanged);
				}
				super.data = value;
				_bitmapDataProvider = (value as IBitmapDataProvider);
				if(_bitmapDataProvider){
					_bitmapDataProvider.bitmapDataChanged.addHandler(onBitmapChanged);
					if(_bitmap)_bitmap.bitmapData = _bitmapDataProvider.bitmapData;
					performMeasChanged();
				}else if(_bitmap){
					_bitmap.bitmapData = null;
				}
				_layoutViewProvider = (value as ILayoutViewProvider);
				if(_layoutViewProvider){
					_layoutViewProvider.layoutViewChanged.addHandler(onViewChanged);
					setLayoutView(_layoutViewProvider.layoutView);
				}else{
					setLayoutView(null);
				}
			}
		}
		
		private var _bitmap:IBitmapAsset;
		private var _bitmapDataProvider:IBitmapDataProvider;
		
		private var _layoutView:ILayoutView;
		private var _layoutViewAsset:IDisplayAsset;
		private var _layoutViewProvider:ILayoutViewProvider;
		
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
		override protected function bindToAsset() : void{
			super.bindToAsset();
			CONFIG::debug{
				_bitmap = _containerAsset.takeAssetByName(AssetNames.DEBUG_ITEM_BITMAP,IBitmapAsset);
			}
			_bitmapPaddingTop = _bitmap.y;
			_bitmapPaddingLeft = _bitmap.x;
			_bitmapPaddingRight = _backing.naturalWidth-(_bitmap.x+_bitmap.naturalWidth);
			_bitmapPaddingBottom = _backing.naturalHeight-(_bitmap.y+_bitmap.naturalHeight);
			if(_bitmapDataProvider)_bitmap.bitmapData = _bitmapDataProvider.bitmapData;
			
			if(_layoutViewAsset){
				_containerAsset.addAsset(_layoutViewAsset);
			}
			performMeasChanged();
		}
		override protected function unbindFromAsset() : void{
			super.unbindFromAsset();
			_containerAsset.returnAsset(_bitmap);
			_bitmap.bitmapData = null;
			_bitmap = null;
			
			if(_layoutViewAsset){
				_containerAsset.removeAsset(_layoutViewAsset);
			}
		}
		override protected function measure() : void{
			super.measure();
			var measH:Number;
			var measW:Number;
			
			if(_bitmap && _bitmap.bitmapData){
				measH = _bitmap.bitmapData.height+_bitmapPaddingTop+_bitmapPaddingBottom;
				measW = _bitmap.bitmapData.width+_bitmapPaddingLeft+_bitmapPaddingRight;
				if(_measurements.x<measW){
					_measurements.x = measW;
				}
				if(_measurements.y<measH){
					_measurements.y = measH;
				}
			}
			if(_layoutView){
				var meas:Point = _layoutView.measurements;
				measH = meas.y+_bitmapPaddingTop+_bitmapPaddingBottom;
				measW = meas.x+_bitmapPaddingLeft+_bitmapPaddingRight;
				if(_measurements.x<measW){
					_measurements.x = measW;
				}
				if(_measurements.y<measH){
					_measurements.y = measH;
				}
			}
		}
		override protected function draw() : void{
			super.draw();
			if(_bitmap){
				_bitmap.x = _bitmapPaddingLeft;
				_bitmap.y = _bitmapPaddingTop;
				_bitmap.width = displayPosition.width-_bitmapPaddingLeft-_bitmapPaddingRight;
				_bitmap.height = displayPosition.height-_bitmapPaddingTop-_bitmapPaddingBottom;
			}
			if(_layoutView){
				_layoutView.setDisplayPosition(_bitmapPaddingLeft,_bitmapPaddingTop,
					displayPosition.width-_bitmapPaddingLeft-_bitmapPaddingRight,
					displayPosition.height-_bitmapPaddingTop-_bitmapPaddingBottom);
			}
		}
		override protected function onChildAdded(e:Event, from:IDisplayAsset) : void{
			super.onChildAdded(e, from);
			if(_layoutViewAsset)_containerAsset.setAssetIndex(_layoutViewAsset,_containerAsset.numChildren-1);
		}
		
		
		
		protected function onBitmapChanged(from:IBitmapDataProvider) : void{
			if(_bitmap)_bitmap.bitmapData = _bitmapDataProvider.bitmapData;
			performMeasChanged();
		}
		protected function onViewChanged(from:ILayoutViewProvider) : void{
			setLayoutView(_layoutViewProvider.layoutView);
		}
		protected function setLayoutView(layoutView:ILayoutView) : void{
			if(_layoutView!=layoutView){
				if(_layoutView){
					_layoutView.assetChanged.removeHandler(onViewAssetChanged);
				}
				_layoutView = layoutView;
				if(_layoutView){
					_layoutView.assetChanged.addHandler(onViewAssetChanged);
					setViewAsset(_layoutView.asset);
				}else{
					setViewAsset(null);
				}
				performMeasChanged();
				invalidate();
			}
		}
		protected function onViewAssetChanged(from:ILayoutView) : void{
			setViewAsset(_layoutView.asset);
		}
		protected function setViewAsset(asset:IDisplayAsset) : void{
			if(_layoutViewAsset!=asset){
				if(_layoutViewAsset && _containerAsset){
					_containerAsset.removeAsset(_layoutViewAsset);
				}
				_layoutViewAsset = asset;
				if(_layoutViewAsset && _containerAsset){
					_containerAsset.addAsset(_layoutViewAsset);
				}
			}
		}
	}
}