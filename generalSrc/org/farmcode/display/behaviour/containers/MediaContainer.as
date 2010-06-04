package org.farmcode.display.behaviour.containers
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	import org.farmcode.display.behaviour.ILayoutViewBehaviour;
	import org.farmcode.display.layout.ILayoutSubject;
	import org.farmcode.display.layout.ProxyLayoutSubject;
	import org.farmcode.display.layout.core.ILayoutInfo;
	import org.farmcode.display.layout.frame.FrameLayout;
	import org.farmcode.display.layout.frame.FrameLayoutInfo;
	import org.farmcode.display.layout.getMarginAffectedArea;
	import org.farmcode.media.IMediaSource;
	
	public class MediaContainer extends ContainerView
	{
		
		public function get mediaSource():IMediaSource{
			return _mediaSource;
		}
		public function set mediaSource(value:IMediaSource):void{
			if(_mediaSource!=value){
				if(_mediaSource){
					_mediaSource.returnMediaDisplay(_mediaSourceDisplay);
					_mediaSourceDisplay.measurementsChanged.removeHandler(onMediaMeasChange);
					_mediaContainer.removeChild(_mediaSourceDisplay.asset);
					_mediaSourceDisplay = null;
					_layoutProxy.target = null;
				}
				_mediaSource = value;
				if(_mediaSource){
					_mediaSourceDisplay = _mediaSource.takeMediaDisplay();
					_mediaSourceDisplay.measurementsChanged.addHandler(onMediaMeasChange);
					_mediaContainer.addChild(_mediaSourceDisplay.asset);
					_layoutProxy.target = _mediaSourceDisplay;
					invalidate();
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
		override public function get displayMeasurements() : Rectangle{
			return _mediaSourceDisplay?_mediaSourceDisplay.displayMeasurements:null;
		}
		
		private var _mediaSource:IMediaSource;
		private var _mediaLayoutInfo:ILayoutInfo;
		private var _mediaSourceDisplay:ILayoutViewBehaviour;
		private var _layoutProxy:ProxyLayoutSubject = new ProxyLayoutSubject();
		private var _layout:FrameLayout = new FrameLayout();
		protected var _mediaContainer:Sprite = new Sprite();
		
		private var _scrollRect:Rectangle = new Rectangle();
		
		private var _mediaBounds:DisplayObject;
		private var _assumedLayoutInfo:FrameLayoutInfo;
		
		public function MediaContainer(asset:DisplayObject=null){
			super(asset);
			_layout.addSubject(_layoutProxy);
		}
		protected function onMediaMeasChange(from:ILayoutSubject, oldX:Number, oldY:Number, oldWidth:Number, oldHeight:Number):void{
			dispatchMeasurementChange();
		}
		override protected function bindToAsset() : void{
			super.bindToAsset()
			_mediaBounds = containerAsset.getChildByName("mediaBounds");
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
				containerAsset.addChildAt(_mediaContainer,containerAsset.getChildIndex(_backing)+1);
			}else{
				containerAsset.addChildAt(_mediaContainer,0);
			}
		}
		override protected function unbindFromAsset() : void{
			super.unbindFromAsset();
			containerAsset.removeChild(_mediaContainer);
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