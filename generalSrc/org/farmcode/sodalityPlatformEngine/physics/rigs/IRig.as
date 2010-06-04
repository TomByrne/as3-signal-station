package org.farmcode.sodalityPlatformEngine.physics.rigs
{
	import Box2D.Dynamics.b2World;
	
	
	public interface IRig
	{
		function create(world:b2World, x:Number, y:Number, scale:Number):void;
		function destroy(world:b2World):void;
		function shiftPos(x:Number, y:Number):void;
	}
}