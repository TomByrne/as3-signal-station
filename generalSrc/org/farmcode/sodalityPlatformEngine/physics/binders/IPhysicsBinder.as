package org.farmcode.sodalityPlatformEngine.physics.binders
{
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2World;
	
	import flash.display.DisplayObject;
	
	public interface IPhysicsBinder
	{
		function create(world:b2World, scale:Number):void;
		function step(world:b2World):void;
		function destroy(world:b2World):void;
		function shift(x:Number, y:Number):void;
		function get body():b2Body;
		function get display():DisplayObject;
	}
}