package org.farmcode.sodalityPlatformEngine.physics.rigs.bicycle
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2World;
	
	import org.farmcode.sodalityPlatformEngine.parallax.IParallaxItem;
	import org.farmcode.sodalityPlatformEngine.physics.IPhysicsItem;
	import org.farmcode.sodalityPlatformEngine.physics.bindables.ParallaxBindable;
	import org.farmcode.sodalityPlatformEngine.physics.binders.RigidBodyBinder;
	import org.farmcode.sodalityPlatformEngine.physics.rigs.IRig;
	import org.farmcode.sodalityPlatformEngine.physics.rigs.IRigSkin;
	
	import flash.display.DisplayObjectContainer;
	import flash.geom.Point;

	public class AnimatedBicycleRig implements IRigSkin
	{
		
		public function create(parent:IPhysicsItem, childContainer:DisplayObjectContainer, rig:IRig, world:b2World, x:Number, y:Number, scale:Number):Array{
			var castRig:BicycleRig = (rig as BicycleRig);
			castRig.create(world, x, y, scale);
			var center:b2Vec2 = castRig.mainCarBody.GetLocalPoint(castRig.chassisBody.GetWorldCenter());
			return [new RigidBodyBinder(castRig.chassisBody,new ParallaxBindable((parent as IParallaxItem).parallaxDisplay),new Point(center.x,center.y))];
		}
		
		public function destroy(parent:DisplayObjectContainer):void{
		}
	}
}