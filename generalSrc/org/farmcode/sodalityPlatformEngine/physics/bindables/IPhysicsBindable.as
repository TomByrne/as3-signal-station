package org.farmcode.sodalityPlatformEngine.physics.bindables
{
	import flash.display.DisplayObject;
	
	public interface IPhysicsBindable
	{
		function get x():Number;
		function set x(value:Number):void;
		function get y():Number;
		function set y(value:Number):void;
		function get rotation():Number;
		function set rotation(value:Number):void;
		function get display():DisplayObject;
	}
}