package au.com.thefarmdigital.parallax
{
	import flash.events.IEventDispatcher;
	import flash.display.DisplayObject;
	
	[Event(name="positionChanged",type="au.com.thefarmdigital.parallax.events.ParallaxEvent")]
	[Event(name="depthChanged",type="au.com.thefarmdigital.parallax.events.ParallaxEvent")]
	[Event(name="displayChanged",type="au.com.thefarmdigital.parallax.events.ParallaxEvent")]
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