package org.tbyrne.display.containers
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObjectContainer;
	import org.tbyrne.display.core.ILayoutView;
	import org.tbyrne.display.layout.ILayoutSubject;
	import org.tbyrne.display.layout.ProxyLayoutSubject;
	import org.tbyrne.display.layout.core.ILayoutInfo;
	import org.tbyrne.display.layout.frame.FrameLayout;
	import org.tbyrne.display.layout.frame.FrameLayoutInfo;
	import org.tbyrne.display.layout.getMarginAffectedArea;
	import org.tbyrne.media.IMediaSource;
	
	public class MediaContainer extends ContainerView
	{
		// asset children
		private static const MEDIA_BOUNDS:String = "mediaBounds";
		
		public function get mediaSource():IMediaSource{
			return _mediaSource;
		}
		public function set mediaSource(value:IMediaSource):void{
			if(_mediaSource!=value){
				if(_mediaSource){
					_mediaSourceDisplay.assetChanged.removeHandler(onMediaAssetChanged);
					_mediaSource.returnMediaDisplay(_mediaSourceDisplay);
					_mediaSourceDisplay = null;
				}
				_mediaSource = value;
				if(_mediaSource){
					_mediaSourceDisplay = _mediaSource.takeMediaDisplay();
					setMediaAsset(_mediaSourceDisplay.asset);
					_mediaSourceDisplay.assetChanged.addHandler(onMediaAssetChanged);
					_layoutProxy.target = _mediaSourceDisplay;
					invalidateSize();
				}else{
					_layoutProxy.target = null;
					setMediaAsset(null);
				}
			}
		}
		
		public function get mediaLayoutInfo():ILayoutInfo{
			return _mediaLayoutInfo;
		}
		public function set mediaLayoutInfo(value:ILayoutInfo):void{
			if(_mediaLayoutInfo!=value){
				_mediaLayoutInfo = value;
				_layoutProxy.layoutInfo = (_mediaLayoutInfo?_mediaLayoutInfo:_assumedLayoutInfo);
			}
		}
		
		protected var _mediaSource:IMediaSource;
		protected var _mediaLayoutInfo:ILayoutInfo;
		protected var _mediaSourceDisplay:ILayoutView;
		protected var _mediaSourceDisplayAsset:IDisplayObject;
		protected var _layoutProxy:ProxyLayoutSubject = new ProxyLayoutSubject();
		protected var _layout:FrameLayout;
		protected var _mediaContainer:IDisplayObjectContainer;
		
		protected var _scrollRect:Rectangle = new Rectangle();
		
		protected var _mediaBounds:IDisplayObject;
		protected var _assumedLayoutInfo:FrameLayoutInfo;
		
		public function MediaContainer(asset:IDisplayObject=null){
			super(asset);
			_layout = new FrameLayout(this)
			_layout.addSubject(_layoutProxy);
			_layout.measurementsChanged.addHandler(onLayoutMeasChange);
		}
		protected function onLayoutMeasChange(from:ILayoutSubject, oldWidth:Number, oldHeight:Number):void{
			invalidateMeasurements();
		}
		override protected function bindToAsset() : void{
			super.bindToAsset()
			_mediaContainer = _asset.factory.createContainer();
			if(_mediaSourceDisplayAsset)_mediaContainer.addAsset(_mediaSourceDisplayAsset);
			_mediaBounds = _containerAsset.takeAssetByName(MEDIA_BOUNDS,IDisplayObject,true);
			if(_mediaBounds){
				if(!_assumedLayoutInfo){
					_assumedLayoutInfo = new FrameLayoutInfo();
				}
				var mediaBounds:Rectangle = _mediaBounds.getBounds(asset);
				var backingBounds:Rectangle = (_backing || asset).getBounds(asset);
				_assumedLayoutInfo.marginTop = mediaBounds.top-backingBounds.top;
				_assumedLayoutInfo.marginLeft = mediaBounds.left-backingBounds.left;
				_assumedLayoutInfo.marginRight = backingBounds.right-mediaBounds.right;
				_assumedLayoutInfo.marginBottom = backingBounds.bottom-mediaBounds.bottom;
				if(!_mediaLayoutInfo){
					_layoutProxy.layoutInfo = _assumedLayoutInfo;
				}
			}
			if(_backing){
				_containerAsset.addAssetAt(_mediaContainer,_containerAsset.getAssetIndex(_backing)+1);
			}else{
				_containerAsset.addAssetAt(_mediaContainer,0);
			}
		}
		override protected function unbindFromAsset() : void{
			super.unbindFromAsset();
			_containerAsset.removeAsset(_mediaContainer);
			
			if(_mediaSourceDisplayAsset)_mediaContainer.removeAsset(_mediaSourceDisplayAsset);
			_asset.factory.destroyAsset(_mediaContainer);
		}
		override protected function measure() : void{
			_measurements.x = _layout.measurements.x;
			_measurements.y = _layout.measurements.y;
		}
		override protected function commitSize() : void{
			super.commitSize();
			_layout.setSize(size.x,size.y);
			getMarginAffectedArea(0,0,size.x,size.y, _layoutProxy.layoutInfo, _scrollRect);
			
			_scrollRect.x -= position.x;
			_scrollRect.y -= position.y;
			_mediaContainer.setPosition(_scrollRect.x,_scrollRect.y);
			_mediaContainer.scrollRect = _scrollRect;
			if(_mediaBounds){
				_mediaBounds.setSizeAndPos(_scrollRect.x,_scrollRect.y,_scrollRect.width,_scrollRect.height);
			}
		}
		
		protected function onMediaAssetChanged(from:ILayoutView, oldAsset:IDisplayObject):void{
			setMediaAsset(_mediaSourceDisplay.asset);
			validateSize(true);
		}
		
		protected function setMediaAsset(asset:IDisplayObject):void{
			if(_mediaSourceDisplayAsset != asset){
				if(_mediaSourceDisplayAsset && _mediaContainer){
					_mediaContainer.removeAsset(_mediaSourceDisplayAsset);
				}
				_mediaSourceDisplayAsset = asset;
				if(_mediaSourceDisplayAsset && _mediaContainer){
					_mediaContainer.addAsset(_mediaSourceDisplayAsset);
				}
			}
		}
		
	}
}