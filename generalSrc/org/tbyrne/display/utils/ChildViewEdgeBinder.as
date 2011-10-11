package org.tbyrne.display.utils
{
	import flash.geom.Point;
	
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
	import org.tbyrne.display.core.ILayoutView;
	import org.tbyrne.display.layout.ILayoutSubject;

	public class ChildViewEdgeBinder
	{
		public static const NONE:String = "bindNone";
		public static const PIXEL:String = "bindPixel";
		public static const PERCENT:String = "bindPercent";
		
		public var obeyMinWidth:Boolean = false;
		public var obeyMinHeight:Boolean = false;
		
		protected var _childAsset:IDisplayObject;
		protected var _childLayout:ILayoutSubject;
		
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
		
		public function get destX():Number{
			return _destX;
		}
		public function get destY():Number{
			return _destY;
		}
		public function get destW():Number{
			return _destW;
		}
		public function get destH():Number{
			return _destH;
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
		
		protected var _destX:Number;
		protected var _destY:Number;
		protected var _destW:Number;
		protected var _destH:Number;
		
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
				_childLayout = (child as ILayoutSubject);
				if(_childLayout){
					childX = _childLayout.position.x;
					childY = _childLayout.position.y;
					childW = _childLayout.size.x;
					childH = _childLayout.size.y;
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
				var meas:Point = _childLayout.measurements;
				minW = meas.x;
				minH = meas.y;
			}
			
			// do Y axis first
			if(doBindTop){
				if(doBindBottom){
					// is bound to both top and bottom
					if(padTop+padBottom+minH>height){
						_destH = (obeyMinHeight?minH:(height-padTop-padBottom));
						_destY = y+padTop+(height-padTop-padBottom-_destH)/2;
					}else{
						_destY = y+padTop;
						_destH = height-padTop-padBottom;
					}
				}else{
					// is bound to top
					if(padTop+minH>height){
						_destY = y+padTop;
						_destH = height-padTop;
					}else{
						_destY = y+padTop;
						_destH = minH;
					}
				}
			}else if(doBindBottom){
				// is bound to bottom
				if(padBottom+minH>height){
					_destH = height-padBottom;
					_destY = y+height-padBottom-_destH;
				}else{
					_destY = y+height-minH-padBottom;
					_destH = minH;
				}
			}
			
			// then X axis
			if(doBindLeft){
				if(doBindRight){
					// is bound to both left and right
					if(padLeft+padRight+minW>width){
						_destW = (obeyMinWidth?minW:(width-padLeft-padRight));
						_destX = x+padLeft+(width-padLeft-padRight-_destW)/2;
					}else{
						_destX = x+padLeft;
						_destW = width-padLeft-padRight;
					}
				}else{
					// is bound to left
					if(padLeft+minW>width){
						_destX = x+padLeft;
						_destW = width-padLeft;
					}else{
						_destX = x+padLeft;
						_destW = minW;
					}
				}
			}else if(doBindRight){
				// is bound to right
				if(padRight+minW>width){
					_destW = width-padRight;
					_destX = x+width-padRight-_destW;
				}else{
					_destX = x+width-minW-padRight;
					_destW = minW;
				}
			}
		}
		public function setSizeAndUpdate(x:Number, y:Number, width:Number, height:Number):void{
			setSize(x,y,width,height);
			if(_childAsset){
				_childAsset.setSizeAndPos(_destX,_destY,_destW,_destH);
			}else{
				_childLayout.setPosition(_destX,_destY);
				_childLayout.setSize(_destW,_destH);
			}
		}
		
		public function release():void{
			_childAsset = null;
			_childLayout = null;
		}
	}
}