package au.com.thefarmdigital.display
{
	import flash.display.DisplayObject;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.farmcode.display.constants.Anchor;
	import org.farmcode.display.constants.Fit;
	import org.farmcode.display.constants.Scale;
	import org.farmcode.display.utils.DisplayFramer;
	
	public class DisplayContainer extends View
	{
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
		public function get displayObject():DisplayObject{
			return _displayObject;
		}
		public function set displayObject(value:DisplayObject):void{
			if(_displayObject!=value){
				if(_displayObject && contains(_displayObject)){
					removeChild(_displayObject);
				}
				_displayObject = value;
				if(_displayObject && !contains(_displayObject)){
					if(_displayObject.parent){
						_displayObject.parent.removeChild(_displayObject);
					}
					addChild(_displayObject);
				}
				invalidate();
			}
		}
		
		
		protected var _displayObject:DisplayObject;
		protected var _padding:Rectangle;
		protected var _anchor:String = Anchor.CENTER;
		protected var _fitPolicy:String = Fit.STRETCH;
		protected var _scaleXPolicy:String = Scale.ALWAYS;
		protected var _scaleYPolicy:String = Scale.ALWAYS;
		
		
		override protected function draw():void{
			var width:Number = this.width;
			var height:Number = this.height;
			
			if(_displayObject){
				var displaySize:Rectangle = getDisplaySize(_displayObject);
				if(displaySize){
					if(displaySize.x && !isNaN(displaySize.x) && isNaN(width)){
						width = displaySize.x;
					}
					if(displaySize.y && !isNaN(displaySize.y) && isNaN(height)){
						height = displaySize.y;
					}
				}
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
				if(displaySize){
					var sizedRect:Rectangle = DisplayFramer.frame(displaySize,mediaArea,anchor,scaleXPolicy,scaleYPolicy,fitPolicy);
					var offset:Point = getChildCenterOffset(_displayObject);
					_displayObject.x = sizedRect.x-offset.x;
					_displayObject.y = sizedRect.y-offset.y;
					_displayObject.width = sizedRect.width;
					_displayObject.height = sizedRect.height;
				}
			}
		}
		protected function getDisplaySize(displayObject:DisplayObject):Rectangle{
			var bounds:Rectangle = displayObject.getBounds(displayObject);
			return bounds;
		}
		protected function getChildCenterOffset(displayObject:DisplayObject):Point{
			var bounds:Rectangle = displayObject.getBounds(this);
			return new Point(bounds.x-displayObject.x,bounds.y-displayObject.y);
		}
	}
}