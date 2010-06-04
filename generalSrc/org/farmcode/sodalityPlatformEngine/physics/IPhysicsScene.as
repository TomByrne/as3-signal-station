package org.farmcode.sodalityPlatformEngine.physics
{
	import Box2D.Dynamics.b2World;
	
	import flash.geom.Rectangle;
	
	public interface IPhysicsScene
	{
		function get physicsSpeed():Number;
		function get physicsGravity():Number;
		function get physicsScale():Number;
		function get physicsBounds():Rectangle;
		function get physicsWorld():b2World;
		function set physicsWorld(value:b2World):void;
	}
}