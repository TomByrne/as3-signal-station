package org.farmcode.sodalityPlatformEngine.physics.bindables
{
	import au.com.thefarmdigital.parallax.IParallaxDisplay;
	
	import flash.display.DisplayObject;
	
	public class ParallaxBindable implements IPhysicsBindable
	{
		private var parallaxDisplay:IParallaxDisplay;
		
		public function ParallaxBindable(parallaxDisplay:IParallaxDisplay){
			this.parallaxDisplay = parallaxDisplay;
		}

		public function get x():Number{
			return parallaxDisplay.position.x;
		}
		
		public function set x(value:Number):void{
			parallaxDisplay.position.x = value;
		}
		
		public function get y():Number{
			return parallaxDisplay.position.y;
		}
		
		public function set y(value:Number):void{
			parallaxDisplay.position.y = value;
		}
		
		public function get rotation():Number{
			return parallaxDisplay.display.rotation;
		}
		
		public function set rotation(value:Number):void{
			parallaxDisplay.display.rotation = value;
		}
		
		public function get display():DisplayObject{
			return parallaxDisplay.display;
		}
	}
}