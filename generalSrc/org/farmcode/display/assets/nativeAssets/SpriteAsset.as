package org.farmcode.display.assets.nativeAssets
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	import org.farmcode.display.assets.assetTypes.ISpriteAsset;

	public class SpriteAsset extends DisplayObjectContainerAsset implements ISpriteAsset
	{
		override public function set displayObject(value:DisplayObject):void{
			if(super.displayObject!=value){
				super.displayObject = value;
				if(value){
					_sprite = value as Sprite;
				}else{
					_sprite = null;
				}
			}
		}
		public function get sprite():Sprite{
			return _sprite;
		}
		
		
		public function get hitArea():ISpriteAsset{
			return _sprite && _sprite.hitArea?_nativeFactory.getNew(_sprite.hitArea):null;
		}
		public function set hitArea(value:ISpriteAsset):void{
			if(value){
				_sprite.hitArea = value.displayObject as Sprite;
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
		
		public function SpriteAsset(factory:NativeAssetFactory=null){
			super(factory);
		}
	}
}