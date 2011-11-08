package org.tbyrne.composeLibrary.display2D
{
	import flash.display.DisplayObject;
	
	import org.tbyrne.compose.traits.AbstractTrait;
	import org.tbyrne.composeLibrary.draw.types.IFrameAwareTrait;
	import org.tbyrne.geom.rect.IRectangleProvider;
	import org.tbyrne.display.constants.Anchor;
	
	public class FrameAlignTrait extends AbstractTrait implements IFrameAwareTrait
	{
		
		public function get offsetX():Number{
			return _offsetX;
		}
		public function set offsetX(value:Number):void{
			if(_offsetX!=value){
				_offsetX = value;
				attemptAlign();
			}
		}
		
		public function get offsetY():Number{
			return _offsetY;
		}
		public function set offsetY(value:Number):void{
			if(_offsetY!=value){
				_offsetY = value;
				attemptAlign();
			}
		}
		
		public function get anchor():String{
			return _anchor;
		}
		public function set anchor(value:String):void{
			if(_anchor!=value){
				_anchor = value;
				attemptAlign();
			}
		}
		
		
		public function get display():DisplayObject{
			return _display;
		}
		public function set display(value:DisplayObject):void{
			if(_display!=value){
				_display = value;
				attemptAlign();
			}
		}
		
		public function get bounds():IRectangleProvider{
			return _bounds;
		}
		public function set bounds(value:IRectangleProvider):void{
			if(_bounds!=value){
				if(_bounds){
					_bounds.rectangleChanged.removeHandler(onRectChanged);
				}
				_bounds = value;
				if(_bounds){
					_bounds.rectangleChanged.addHandler(onRectChanged);
				}
				attemptAlign();
			}
		}
		
		private var _bounds:IRectangleProvider;
		private var _anchor:String;
		private var _display:DisplayObject;
		private var _width:Number;
		private var _height:Number;
		private var _offsetY:Number;
		private var _offsetX:Number;
		
		public function FrameAlignTrait(display:DisplayObject=null, anchor:String=null, bounds:IRectangleProvider=null){
			super();
			
			this.display = display;
			this.anchor = anchor;
			this.bounds = bounds;
		}
		
		private function onRectChanged(from:IRectangleProvider):void{
			attemptAlign();
		}
		
		public function setSize(width:Number, height:Number):void{
			_width = width;
			_height = height;
			attemptAlign();
		}
		
		private function attemptAlign():void{
			if(_display && _anchor){
				var boundsX:Number;
				var boundsY:Number;
				var boundsW:Number;
				var boundsH:Number;
				
				if(_bounds){
					boundsX = _bounds.x;
					boundsY = _bounds.y;
					boundsW = _bounds.width;
					boundsH = _bounds.height;
				}else{
					boundsX = 0;
					boundsY = 0;
					boundsW = 0;
					boundsH = 0;
				}
				
				var x:Number;
				var y:Number;
				switch(_anchor){
					case Anchor.TOP:
					case Anchor.TOP_LEFT:
					case Anchor.TOP_RIGHT:
						y = -boundsY;
						break;
					case Anchor.BOTTOM:
					case Anchor.BOTTOM_LEFT:
					case Anchor.BOTTOM_RIGHT:
						y = _height-boundsH-boundsY;
						break;
					default:
						y = (_height-boundsH-boundsY)/2;
				}
				switch(_anchor){
					case Anchor.LEFT:
					case Anchor.TOP_LEFT:
					case Anchor.BOTTOM_RIGHT:
						x = -boundsX;
						break;
					case Anchor.RIGHT:
					case Anchor.TOP_RIGHT:
					case Anchor.BOTTOM_RIGHT:
						x = _width-boundsW-boundsX;
						break;
					default:
						x = (_width-boundsW-boundsX)/2;
				}
				if(!isNaN(_offsetX)){
					x += _offsetX;
				}
				if(!isNaN(_offsetY)){
					y += _offsetY;
				}
				_display.x = x;
				_display.y = y;
			}
		}
	}
}