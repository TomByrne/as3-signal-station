package org.farmcode.display.assets.nativeAssets
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	import org.farmcode.display.assets.IDisplayAsset;
	import org.farmcode.display.assets.IGraphicsAsset;
	import org.farmcode.display.assets.ISpriteAsset;

	public class SpriteAsset extends DisplayObjectContainerAsset implements ISpriteAsset
	{
		override public function set displayObject(value:DisplayObject):void{
			if(super.displayObject!=value){
				if(_graphics){
					_graphics.graphics = null;
				}
				super.displayObject = value;
				if(value){
					_sprite = value as Sprite;
					if(_graphics){
						_graphics.graphics = _sprite.graphics;
					}
				}else{
					_sprite = null;
				}
			}
		}
		public function get sprite():Sprite{
			return _sprite;
		}
		
		
		public function get hitArea():ISpriteAsset{
			return _sprite && _sprite.hitArea?NativeAssetFactory.getNew(_sprite.hitArea):null;
		}
		public function set hitArea(value:ISpriteAsset):void{
			if(value){
				var cast:SpriteAsset = (value as SpriteAsset);
				_sprite.hitArea = cast.sprite;
			}else{
				_sprite.hitArea = null;
			}
		}
		public function get useHandCursor():Boolean{
			return _sprite.useHandCursor;
		}
		public function set useHandCursor(value:Boolean):void{
			_sprite.useHandCursor = value;
		}
		public function get buttonMode():Boolean{
			return _sprite.buttonMode;
		}
		public function set buttonMode(value:Boolean):void{
			_sprite.buttonMode = value;
		}
		
		private var _sprite:Sprite;
		private var _graphics:GraphicsAsset;
		
		public function SpriteAsset(){
			super();
		}
		
		public function get graphics():IGraphicsAsset{
			if(!_graphics){
				_graphics = new GraphicsAsset();
				_graphics.graphics = _sprite.graphics;
			}
			return _graphics;
		}
	}
}