package org.farmcode.sodalityPlatformEngine.physics.rigs
{
	import Box2D.Dynamics.b2World;
	
	import org.farmcode.sodalityPlatformEngine.physics.IPhysicsItem;
	
	import flash.display.DisplayObjectContainer;
	
	public interface IRigSkin
	{
		function create(parent:IPhysicsItem, childContainer:DisplayObjectContainer, rig:IRig, world:b2World, x:Number, y:Number, scale:Number):Array;
		function destroy(parent:DisplayObjectContainer):void;
	}
}