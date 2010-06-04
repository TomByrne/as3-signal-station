package org.farmcode.sodalityPlatformEngine.physics.items
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	
	public class SimplePhysicsItem extends PhysicsItem
	{
		public function get image():DisplayObject{
			return _image;
		}
		public function set image(value:DisplayObject):void{
			if(_image!=value){
				if(_image){
					_parallaxContainer.removeChild(_image);
				}
				_image = value;
				if(_image){
					_parallaxContainer.addChild(_image);
				}
			}
		}
		
		private var _image:DisplayObject;
		private var _parallaxContainer:DisplayObjectContainer;
		
		public function SimplePhysicsItem(){
			_parallaxDisplay.display = _parallaxContainer = new Sprite();
		}
	}
}