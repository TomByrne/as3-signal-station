package au.com.thefarmdigital.display
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.farmcode.display.constants.Anchor;
	import org.farmcode.display.constants.Fit;
	import org.farmcode.display.constants.Scale;
	import org.farmcode.display.utils.DisplayFramer;
	
	/**
	 * The MediaView class is used to scale and crop content according to it's fitPolicy and scalePolicy.
	 */
	public class MediaView extends View
	{
		public function get frameBackground():DisplayObject{
			return _frameBackground;
		}
		public function set frameBackground(value:DisplayObject):void{
			if(_frameBackground!=value){
				if(_frameBackground)removeChild(_frameBackground);
				_frameBackground = value;
				if(value.parent && value.parent!=this)value.parent.removeChild(value);
				if(!value.parent)addChild(value);
				depthsInvalid = true;
				invalidate();
			}
		}
		public function get loadIndicator():DisplayObject{
			return _loadIndicator;
		}
		public function set loadIndicator(value:DisplayObject):void{
			if(_loadIndicator!=value){
				if(_loadIndicator)removeChild(_loadIndicator);
				_loadIndicator = value;
				if(_loadIndicator){
					if(value.parent && value.parent!=this)value.parent.removeChild(value);
					if(!value.parent)addChild(value);
					_loadIndicator.visible = showLoadIndicator();
					depthsInvalid = true;
				}
				invalidate();
			}
		}
		public function get frameForeground():DisplayObject{
			return _frameForeground;
		}
		public function set frameForeground(value:DisplayObject):void{
			if(_frameForeground!=value){
				if(_frameForeground)removeChild(_frameForeground);
				_frameForeground = value;
				if(value.parent && value.parent!=this)value.parent.removeChild(value);
				if(!value.parent)addChild(value);
				depthsInvalid = true;
				invalidate();
			}
		}
		[Inspectable(name="Anchor", category="Styles",defaultValue="C", 
			enumeration="C,TL,T,TR,L,R,BL,B,BR",type="List")]
		public function get anchor():String{
			return _anchor;
		}
		public function set anchor(value:String):void{
			if(_anchor!=value){
				_anchor = value;
				invalidate();
			}
		}
		[Inspectable(name="Fit Policy", category="Styles",defaultValue="fitStretch", 
			enumeration="fitStretch,fitInside,fitExact",type="List")]
		public function get fitPolicy():String{
			return _fitPolicy;
		}
		public function set fitPolicy(value:String):void{
			if(_fitPolicy!=value){
				_fitPolicy = value;
				invalidate();
			}
		}
		public function get scalePolicy():String{
			return (_scaleXPolicy==_scaleYPolicy?_scaleXPolicy:null);
		}
		public function set scalePolicy(value:String):void{
			if(scalePolicy!=value){
				_scaleXPolicy = _scaleYPolicy = value;
				invalidate();
			}
		}
		[Inspectable(name="Scale X Policy", category="Styles", defaultValue="scaleAlways", 
			enumeration="scaleAlways,scaleNever,scaleUpOnly,scaleDownOnly",	type="List")]
		public function get scaleXPolicy():String{
			return _scaleXPolicy;
		}
		public function set scaleXPolicy(value:String):void{
			if(_scaleXPolicy!=value){
				_scaleXPolicy = value;
				invalidate();
			}
		}
		[Inspectable(name="Scale Y Policy", category="Styles", defaultValue="scaleAlways", 
			enumeration="scaleAlways,scaleNever,scaleUpOnly,scaleDownOnly",	type="List")]
		public function get scaleYPolicy():String{
			return _scaleYPolicy;
		}
		public function set scaleYPolicy(value:String):void{
			if(_scaleYPolicy!=value){
				_scaleYPolicy = value;
				invalidate();
			}
		}
		public function get padding():Rectangle{
			return _padding;
		}
		public function set padding(value:Rectangle):void{
			if(_padding!=value){
				_padding = value;
				invalidate();
			}
		}
		
		protected var _frameBackground:DisplayObject;
		protected var _frameForeground:DisplayObject;
		protected var _loadIndicator:DisplayObject;
		protected var _media:DisplayObject;
		protected var _padding:Rectangle;
		protected var _anchor:String = Anchor.CENTER;
		protected var _fitPolicy:String = Fit.STRETCH;
		protected var _scaleXPolicy:String = Scale.ALWAYS;
		protected var _scaleYPolicy:String = Scale.ALWAYS;
		protected var depthsInvalid:Boolean = false;
		protected var _destMediaArea:Rectangle;
		
		public function MediaView(){
			if(_frameBackground && _frameBackground.scale9Grid){
				var grid:Rectangle = _frameBackground.scale9Grid;
				_padding = new Rectangle(grid.x,grid.y,_frameBackground.width-grid.x-grid.width,_frameBackground.height-grid.y-grid.height);
			}
		}
		
		override protected function updateSizeFromBounds(): void{
			var bounds:Rectangle = getBounds(parent?parent:this);
			var size:Point = new Point(bounds.width,bounds.height);
			super.scaleX = super.scaleY = 1;
			width = size.x;
			height = size.y;
		}
		
		public function get mediaWidth(): Number
		{
			validate();
			var w: Number = NaN;
			if (destMediaArea)
			{
				w = this.destMediaArea.width;
			}
			return w;
		}
		
		public function get mediaHeight(): Number
		{
			validate();
			var h: Number = NaN;
			if (destMediaArea)
			{
				h = this.destMediaArea.height;
			}
			return h;
		}
		
		public function get mediaX(): Number
		{
			validate();
			var mX: Number = NaN;
			if (destMediaArea)
			{
				mX = this.destMediaArea.x;
			}
			return mX;
		}
		
		public function get mediaY(): Number
		{
			validate();
			var mY: Number = NaN;
			if (destMediaArea)
			{
				mY = this.destMediaArea.y;
			}
			return mY;
		}
		
		public function get destMediaArea(): Rectangle{
			validate();
			return _destMediaArea;
		}
		
		protected function eventInvalidate(e:Event=null):void{
			invalidate();
		}
		override protected function draw():void{
			if(depthsInvalid && _media){
				depthsInvalid = false;
				if(_loadIndicator && getChildIndex(_media)<getChildIndex(_loadIndicator)){
					swapChildren(_loadIndicator,_media);
				}
				if(_frameForeground && getChildIndex(_media)>getChildIndex(_frameForeground)){
					swapChildren(_frameForeground,_media);
				}
				if(_frameBackground && getChildIndex(_media)<getChildIndex(_frameBackground)){
					swapChildren(_frameBackground,_media);
				}
			}
			
			var width:Number = this.width;
			var height:Number = this.height;
			
			if(_media){
				var dimensions:Rectangle = getMediaDimensions();
				if(dimensions){
					if(dimensions.x && !isNaN(dimensions.x) && isNaN(width)){
						width = dimensions.x;
					}
					if(dimensions.y && !isNaN(dimensions.y) && isNaN(height)){
						height = dimensions.y;
					}
					_destMediaArea = DisplayFramer.frame(dimensions, mediaBoundary,anchor,scaleXPolicy,scaleYPolicy,fitPolicy);
				}else{
					_destMediaArea = null;
				}
				_media.visible = mediaLoaded();
				if(dimensions){
					_destMediaArea = DisplayFramer.frame(dimensions, mediaBoundary,anchor,scaleXPolicy,scaleYPolicy,fitPolicy);
					_media.x = _destMediaArea.x;
					_media.y = _destMediaArea.y;
					_media.width = _destMediaArea.width;
					_media.height = _destMediaArea.height;
				}else{
					_destMediaArea = null;
				}
			}else{
				_destMediaArea = null;
			}
			var scrollRect:Rectangle = new Rectangle(0,0,width,height);
			if(_destMediaArea && !scrollRect.containsRect(_destMediaArea)){
				this.scrollRect = scrollRect;
			}else{
				this.scrollRect = null;
			}
			if(_loadIndicator){
				_loadIndicator.visible = showLoadIndicator();
				_loadIndicator.x = (width-_loadIndicator.width)/2;
				_loadIndicator.y = (height-_loadIndicator.height)/2;
			}
			if(_frameBackground){
				_frameBackground.width = width
				_frameBackground.height = height
			}
			if(_frameForeground){
				_frameForeground.width = width;
				_frameForeground.height = height;
			}
		}
		
		protected function get mediaBoundary(): Rectangle
		{
			var mediaArea:Rectangle = new Rectangle();
			if(_padding){
				mediaArea.x = _padding.x;
				mediaArea.y = _padding.y;
				mediaArea.width = width-_padding.x-_padding.width;
				mediaArea.height = height-_padding.y-_padding.height;
			}else{
				mediaArea.x = 0;
				mediaArea.y = 0;
				mediaArea.width = width;
				mediaArea.height = height;
			}
			return mediaArea;
		}
		// override these
		protected function mediaLoaded():Boolean{
			return false;
		}
		protected function getMediaDimensions():Rectangle{
			return null;
		}
		protected function showLoadIndicator():Boolean{
			return (_media && !mediaLoaded());
		}
	}
}