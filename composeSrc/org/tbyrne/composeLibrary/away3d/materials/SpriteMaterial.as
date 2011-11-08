package org.tbyrne.composeLibrary.away3d.materials
{
	import away3d.arcane;
	import away3d.materials.BitmapMaterial;
	import away3d.tools.utils.TextureUtils;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	
	use namespace arcane;
	
	public class SpriteMaterial extends BitmapMaterial
	{
		
		public function get displayObject():DisplayObject{
			return _displayObject;
		}
		public function set displayObject(value:DisplayObject):void{
			if(_displayObject!=value){
				if(_displayObject && _renderOnFrame){
					_displayObject.removeEventListener(Event.ENTER_FRAME,onEnterFrame);
				}
				_displayObject = value;
				if(_displayObject && _renderOnFrame){
					_displayObject.addEventListener(Event.ENTER_FRAME,onEnterFrame);
				}
				redraw();
			}
		}
		
		public function get renderOnFrame():Boolean{
			return _renderOnFrame;
		}
		public function set renderOnFrame(value:Boolean):void{
			if(_renderOnFrame!=value){
				if(_displayObject && _renderOnFrame){
					_displayObject.removeEventListener(Event.ENTER_FRAME,onEnterFrame);
				}
				_renderOnFrame = value;
				if(_displayObject && _renderOnFrame){
					_displayObject.addEventListener(Event.ENTER_FRAME,onEnterFrame);
				}
			}
		}
		
		private var _renderOnFrame:Boolean;
		private var _displayObject:DisplayObject;
		private var _matrix:Matrix = new Matrix();
		
		
		public function SpriteMaterial(display:DisplayObject=null, renderOnFrame:Boolean=false)
		{
			super();
			
			this.displayObject = display;
			this.renderOnFrame = renderOnFrame;
		}
		private function onEnterFrame(event:Event):void{
			redraw();
		}
		public function redraw():void{
			
			if(_displayObject){
				
				var rect :Rectangle = _displayObject.getBounds(_displayObject);
				var W:int = TextureUtils.getBestPowerOf2(rect.width);
				var H:int = TextureUtils.getBestPowerOf2(rect.height);
				
				if(W==1)W = 2;
				if(H==1)H = 2;
				
				var text:BitmapData = bitmapData;
				if(!text || W!=text.width || H!=text.height){
					if(text){
						text.dispose();
					}
					text = new BitmapData(W, H, true, 0x00FFFFFF);
					text.lock();
					bitmapData = text;
				}else{
					text.lock();
					text.fillRect(text.rect,0x00FFFFFF);
				}
				
				_matrix.tx = -rect.left;
				_matrix.ty = -rect.top;
				_matrix.a = W/rect.width;
				_matrix.d = H/rect.height;
				
				text.draw(_displayObject, _matrix, null, null, null, true);
				text.unlock();
				
			}else if(bitmapData){
				bitmapData.dispose();
				bitmapData = null;
			}
		}
	}
}
