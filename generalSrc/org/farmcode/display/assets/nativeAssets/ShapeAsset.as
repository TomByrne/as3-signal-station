package org.farmcode.display.assets.nativeAssets
{
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Shape;
	
	import org.farmcode.display.assets.IGraphicsAsset;
	import org.farmcode.display.assets.IShapeAsset;
	
	public class ShapeAsset extends DisplayObjectAsset implements IShapeAsset
	{
		override public function set displayObject(value:DisplayObject):void{
			if(super.displayObject!=value){
				if(_graphics){
					_graphics.graphics = null;
				}
				super.displayObject = value;
				if(value){
					_shape = value as Shape;
					if(_graphics){
						_graphics.graphics = _shape.graphics;
					}
				}else{
					_shape = null;
				}
			}
		}
		
		private var _shape:Shape;
		private var _graphics:GraphicsAsset;
		
		public function ShapeAsset(){
			super();
		}
		
		public function get graphics():IGraphicsAsset{
			if(!_graphics){
				_graphics = new GraphicsAsset();
				_graphics.graphics = _shape.graphics;
			}
			return _graphics;
		}
	}
}