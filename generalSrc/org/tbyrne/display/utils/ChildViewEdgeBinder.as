package org.tbyrne.display.utils
{
	import flash.geom.Point;
	
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
	import org.tbyrne.display.core.ILayoutView;

	public class ChildViewEdgeBinder
	{
		public static const NONE:String = "bindNone";
		public static const PIXEL:String = "bindPixel";
		public static const PERCENT:String = "bindPercent";
		
		public var obeyMinWidth:Boolean = false;
		public var obeyMinHeight:Boolean = false;
		
		protected var _childAsset:IDisplayObject;
		protected var _childView:ILayoutView;
		
		public function get paddingPixelTop():Number{
			return _paddingPixelTop;
		}
		public function get paddingPixelBottom():Number{
			return _paddingPixelBottom;
		}
		public function get paddingPixelLeft():Number{
			return _paddingPixelLeft;
		}
		public function get paddingPixelRight():Number{
			return _paddingPixelRight;
		}
		
		protected var _paddingPixelTop:Number;
		protected var _paddingPixelBottom:Number;
		protected var _paddingPixelLeft:Number;
		protected var _paddingPixelRight:Number;
		
		protected var _paddingPercTop:Number;
		protected var _paddingPercBottom:Number;
		protected var _paddingPercLeft:Number;
		protected var _paddingPercRight:Number;
		
		protected var _bindTop:String;
		protected var _bindBottom:String;
		protected var _bindLeft:String;
		protected var _bindRight:String;
		
		public function ChildViewEdgeBinder(){
		}
		
		public function bind(child:*, bounds:*, bindTop:String=PIXEL, bindBottom:String=PIXEL, bindLeft:String=PIXEL, bindRight:String=PIXEL):void{
			_bindTop = bindTop;
			_bindBottom = bindBottom;
			_bindLeft = bindLeft;
			_bindRight = bindRight;
			
			var boundsX:Number;
			var boundsY:Number;
			var boundsW:Number;
			var boundsH:Number;
			
			var boundsAsset:IDisplayObject = (bounds as IDisplayObject);
			if(boundsAsset){
				boundsX = boundsAsset.x;
				boundsY = boundsAsset.x;
				boundsW = boundsAsset.width;
				boundsH = boundsAsset.height;
			}else{
				var boundsView:ILayoutView = (bounds as ILayoutView);
				if(boundsView){
					boundsX = boundsView.position.x;
					boundsY = boundsView.position.y;
					boundsW = boundsView.size.x;
					boundsH = boundsView.size.y;
				}else{
					throw new ArgumentError("Unrecognised bounds");
				}
			}
			
			
			var childX:Number;
			var childY:Number;
			var childW:Number;
			var childH:Number;
			
			_childAsset = (child as IDisplayObject);
			if(_childAsset){
				childX = _childAsset.x;
				childY = _childAsset.y;
				childW = _childAsset.width;
				childH = _childAsset.height;
			}else{
				_childView = (child as ILayoutView);
				if(_childView){
					childX = _childView.position.x;
					childY = _childView.position.y;
					childW = _childView.size.x;
					childH = _childView.size.y;
				}else{
					throw new ArgumentError("Unrecognised child");
				}
			}
			
			_paddingPixelTop = childY-boundsY;
			_paddingPixelLeft = childX-boundsX;
			_paddingPixelBottom = (boundsY+boundsH)-(childY+childH);
			_paddingPixelRight = (boundsX+boundsW)-(childX+childW);
			
			_paddingPercTop = _paddingPixelTop/boundsH;
			_paddingPercLeft = _paddingPixelLeft/boundsW;
			_paddingPercBottom = _paddingPixelBottom/boundsH;
			_paddingPercRight = _paddingPixelRight/boundsW;
		}
		
		public function setSize(x:Number, y:Number, width:Number, height:Number):void{
			var destX:Number;
			var destY:Number;
			var destW:Number;
			var destH:Number;
			
			var padTop:Number;
			var padBottom:Number;
			var padLeft:Number;
			var padRight:Number;
			
			var doBindTop:Boolean;
			var doBindBottom:Boolean;
			var doBindLeft:Boolean;
			var doBindRight:Boolean;
			
			if(_bindTop==PERCENT){
				padTop = _paddingPercTop*height;
				doBindTop = true;
			}else if(_bindTop==PIXEL){
				padTop = _paddingPixelTop;
				doBindTop = true;
			}
			
			if(_bindBottom==PERCENT){
				padBottom = _paddingPercBottom*height;
				doBindBottom = true;
			}else if(_bindBottom==PIXEL){
				padBottom = _paddingPixelBottom;
				doBindBottom = true;
			}
			
			if(_bindLeft==PERCENT){
				padLeft = _paddingPercLeft*width;
				doBindLeft = true;
			}else if(_bindLeft==PIXEL){
				padLeft = _paddingPixelLeft;
				doBindLeft = true;
			}
			
			if(_bindRight==PERCENT){
				padRight = _paddingPercRight*width;
				doBindRight = true;
			}else if(_bindRight==PIXEL){
				padRight = _paddingPixelRight;
				doBindRight = true;
			}
			
			var minW:Number;
			var minH:Number;
			
			if(_childAsset){
				minW = _childAsset.naturalWidth;
				minH = _childAsset.naturalHeight;
			}else{
				var meas:Point = _childView.measurements;
				minW = meas.x;
				minH = meas.y;
			}
			
			// do Y axis first
			if(doBindTop){
				if(doBindBottom){
					// is bound to both top and bottom
					if(padTop+padBottom+minH>height){
						destH = (obeyMinHeight?minH:(height-padTop-padBottom));
						destY = y+padTop+(height-padTop-padBottom-destH)/2;
					}else{
						destY = y+padTop;
						destH = height-padTop-padBottom;
					}
				}else{
					// is bound to top
					if(padTop+minH>height){
						destY = y+padTop;
						destH = height-padTop;
					}else{
						destY = y+padTop;
						destH = minH;
					}
				}
			}else if(doBindBottom){
				// is bound to bottom
				if(padBottom+minH>height){
					destH = height-padBottom;
					destY = y+height-padBottom-destH;
				}else{
					destY = y+height-minH-padBottom;
					destH = minH;
				}
			}
			
			// then X axis
			if(doBindLeft){
				if(doBindRight){
					// is bound to both left and right
					if(padLeft+padRight+minW>width){
						destW = (obeyMinWidth?minW:(width-padLeft-padRight));
						destX = x+padLeft+(width-padLeft-padRight-destW)/2;
					}else{
						destX = x+padLeft;
						destW = width-padLeft-padRight;
					}
				}else{
					// is bound to left
					if(padLeft+minW>width){
						destX = x+padLeft;
						destW = width-padLeft;
					}else{
						destX = x+padLeft;
						destW = minW;
					}
				}
			}else if(doBindRight){
				// is bound to right
				if(padRight+minW>width){
					destW = width-padRight;
					destX = x+width-padRight-destW;
				}else{
					destX = x+width-minW-padRight;
					destW = minW;
				}
			}
			
			if(_childAsset){
				_childAsset.setSizeAndPos(destX,destY,destW,destH);
			}else{
				_childView.setPosition(destX,destY);
				_childView.setSize(destW,destH);
			}
		}
		
		public function release():void{
			_childAsset = null;
			_childView = null;
		}
	}
}