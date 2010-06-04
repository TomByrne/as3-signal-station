package org.farmcode.sodalityPlatformEngine.physics
{
	import Box2D.Dynamics.b2World;
	
	import flash.geom.Point;
	
	public interface IPhysicsItem
	{
		function get addToPhysics():Boolean;
		function createPhysics(world:b2World, scale:Number):void;
		function destroyPhysics(world:b2World):void;
		function stepPhysics():void;
		function applyImpulse(impulse:Point):void;
	}
}