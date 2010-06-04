package org.farmcode.sodalityPlatformEngine.physics.bindables
{
	import flash.display.DisplayObject;
	
	public class BindableProxy implements IPhysicsBindable
	{
		protected var displayObject:DisplayObject;
		
		public function BindableProxy(displayObject:DisplayObject){
			this.displayObject = displayObject;
		}

		public function get x():Number{
			return displayObject.x;
		}
		
		public function set x(value:Number):void{
			displayObject.x = value;
		}
		
		public function get y():Number{
			return displayObject.y;
		}
		
		public function set y(value:Number):void{
			displayObject.y = value;
		}
		
		public function get rotation():Number{
			return displayObject.rotation;
		}
		
		public function set rotation(value:Number):void{
			displayObject.rotation = value;
		}
		
		public function get display():DisplayObject{
			return displayObject;
		}
	}
}