package org.tbyrne.display.parallax
{
	import flash.events.IEventDispatcher;
	import flash.display.DisplayObject;
	
	[Event(name="positionChanged",type="org.tbyrne.display.parallax.events.ParallaxEvent")]
	[Event(name="depthChanged",type="org.tbyrne.display.parallax.events.ParallaxEvent")]
	[Event(name="displayChanged",type="org.tbyrne.display.parallax.events.ParallaxEvent")]
	public interface IParallaxDisplay extends IEventDispatcher
	{
		//function get parallaxChildren():Array;
		function set parallaxParent(value:IParallaxDisplay):void;
		function get parallaxParent():IParallaxDisplay;
		function get position():Point3D;
		function get display():DisplayObject;
		function get cameraDepth():Number;
		function set cameraDepth(value:Number):void;
	}
}