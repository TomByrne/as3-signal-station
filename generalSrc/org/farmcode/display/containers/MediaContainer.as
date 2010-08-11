package org.farmcode.display.containers
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	import org.farmcode.display.assets.IContainerAsset;
	import org.farmcode.display.assets.IDisplayAsset;
	import org.farmcode.display.core.ILayoutView;
	import org.farmcode.display.layout.ILayoutSubject;
	import org.farmcode.display.layout.ProxyLayoutSubject;
	import org.farmcode.display.layout.core.ILayoutInfo;
	import org.farmcode.display.layout.frame.FrameLayout;
	import org.farmcode.display.layout.frame.FrameLayoutInfo;
	import org.farmcode.display.layout.getMarginAffectedArea;
	import org.farmcode.media.IMediaSource;
	
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
					_mediaSource.returnMediaDisplay(_mediaSourceDisplay);
					if(_mediaContainer)_mediaContainer.removeAsset(_mediaSourceDisplay.asset);
					_mediaSourceDisplay = null;
				}
				_mediaSource = value;
				if(_mediaSource){
					_mediaSourceDisplay = _mediaSource.takeMediaDisplay();
					if(_mediaContainer)_mediaContainer.addAsset(_mediaSourceDisplay.asset);
					_layoutProxy.target = _mediaSourceDisplay;
					invalidate();
				}else{
					_layoutProxy.target = null;
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
		protected var _layoutProxy:ProxyLayoutSubject = new ProxyLayoutSubject();
		protected var _layout:FrameLayout;
		protected var _mediaContainer:IContainerAsset;
		
		protected var _scrollRect:Rectangle = new Rectangle();
		
		protected var _mediaBounds:IDisplayAsset;
		protected var _assumedLayoutInfo:FrameLayoutInfo;
		
		public function MediaContainer(asset:IDisplayAsset=null){
			super(asset);
			_layout = new FrameLayout(this)
			_layout.addSubject(_layoutProxy);
			_layout.measurementsChanged.addHandler(onLayoutMeasChange);
		}
		protected function onLayoutMeasChange(from:ILayoutSubject, oldWidth:Number, oldHeight:Number):void{
			dispatchMeasurementChange();
		}
		override protected function bindToAsset() : void{
			super.bindToAsset()
			_mediaContainer = _asset.createAsset(IContainerAsset);
			if(_mediaSourceDisplay)_mediaContainer.addAsset(_mediaSourceDisplay.asset);
			_mediaBounds = _containerAsset.takeAssetByName(MEDIA_BOUNDS,IDisplayAsset,true);
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
			
			if(_mediaSourceDisplay)_mediaContainer.removeAsset(_mediaSourceDisplay.asset);
			_asset.destroyAsset(_mediaContainer);
		}
		override protected function measure() : void{
			_measurements.x = _layout.measurements.x;
			_measurements.y = _layout.measurements.y;
		}
		override protected function draw() : void{
			super.draw();
			_layout.setDisplayPosition(0,0,displayPosition.width,displayPosition.height);
			getMarginAffectedArea(displayPosition, _layoutProxy.layoutInfo, _scrollRect);
			
			_scrollRect.x -= displayPosition.x;
			_scrollRect.y -= displayPosition.y;
			_mediaContainer.x = _scrollRect.x;
			_mediaContainer.y = _scrollRect.y;
			_mediaContainer.scrollRect = _scrollRect;
			if(_mediaBounds){
				_mediaBounds.x = _scrollRect.x;
				_mediaBounds.y = _scrollRect.y;
				_mediaBounds.width = _scrollRect.width;
				_mediaBounds.height = _scrollRect.height;
			}
		}
	}
}