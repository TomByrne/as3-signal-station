package org.farmcode.sodalityPlatformEngine.physics.rigs.biped
{
	import Box2D.Dynamics.b2World;
	
	import org.farmcode.sodalityPlatformEngine.parallax.IParallaxItem;
	import org.farmcode.sodalityPlatformEngine.physics.IPhysicsItem;
	import org.farmcode.sodalityPlatformEngine.physics.bindables.BindableProxy;
	import org.farmcode.sodalityPlatformEngine.physics.bindables.ParallaxBindable;
	import org.farmcode.sodalityPlatformEngine.physics.binders.RigidBodyBinder;
	import org.farmcode.sodalityPlatformEngine.physics.rigs.IRig;
	import org.farmcode.sodalityPlatformEngine.physics.rigs.IRigSkin;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;

	public class SimpleBipedSkin implements IRigSkin
	{
		protected var _physicsBinders:Array;
		
		public var avatarDisplay:DisplayObjectContainer;
		
		
		public function create(parent:IPhysicsItem, childContainer:DisplayObjectContainer, rig:IRig, world:b2World, x:Number, y:Number, scale:Number):Array{
			_physicsBinders = [];
			if(rig is BipedRig){
				var headDisplay:DisplayObject = avatarDisplay.getChildByName("head");
				var shoulderDisplay:DisplayObject = avatarDisplay.getChildByName("shoulder");
				var waistDisplay:DisplayObject = avatarDisplay.getChildByName("waist");
				var hipDisplay:DisplayObject = avatarDisplay.getChildByName("hip");
			
				var leftUpperArmDisplay:DisplayObject = avatarDisplay.getChildByName("leftUpperArm");
				var rightUpperArmDisplay:DisplayObject = avatarDisplay.getChildByName("rightUpperArm");
				var leftLowerArmDisplay:DisplayObject = avatarDisplay.getChildByName("leftLowerArm");
				var rightLowerArmDisplay:DisplayObject = avatarDisplay.getChildByName("rightLowerArm");
				
				var leftUpperLegDisplay:DisplayObject = avatarDisplay.getChildByName("leftUpperLeg");
				var rightUpperLegDisplay:DisplayObject = avatarDisplay.getChildByName("rightUpperLeg");
				var leftLowerLegDisplay:DisplayObject = avatarDisplay.getChildByName("leftLowerLeg");
				var rightLowerLegDisplay:DisplayObject = avatarDisplay.getChildByName("rightLowerLeg");
				
				var castRig:BipedRig = rig as BipedRig;
				castRig.create(world, x, y, scale);
				
				
				_physicsBinders.push(new RigidBodyBinder(castRig.waistBody,new ParallaxBindable((parent as IParallaxItem).parallaxDisplay)));
				
				_physicsBinders.push(new RigidBodyBinder(castRig.headBody,new BindableProxy(headDisplay),null,null,true,castRig.waistBody));
				_physicsBinders.push(new RigidBodyBinder(castRig.shoulderBody,new BindableProxy(shoulderDisplay),null,null,true,castRig.waistBody));
				_physicsBinders.push(new RigidBodyBinder(castRig.waistBody,new BindableProxy(waistDisplay),null,null,true,castRig.waistBody));
				_physicsBinders.push(new RigidBodyBinder(castRig.hipBody,new BindableProxy(hipDisplay),null,null,true,castRig.waistBody));
				
				_physicsBinders.push(new RigidBodyBinder(castRig.leftUpperArmBody,new BindableProxy(leftUpperArmDisplay),null,null,true,castRig.waistBody));
				_physicsBinders.push(new RigidBodyBinder(castRig.rightUpperArmBody,new BindableProxy(rightUpperArmDisplay),null,null,true,castRig.waistBody));
				_physicsBinders.push(new RigidBodyBinder(castRig.leftLowerArmBody,new BindableProxy(leftLowerArmDisplay),null,null,true,castRig.waistBody));
				_physicsBinders.push(new RigidBodyBinder(castRig.rightLowerArmBody,new BindableProxy(rightLowerArmDisplay),null,null,true,castRig.waistBody));
				
				_physicsBinders.push(new RigidBodyBinder(castRig.leftUpperLegBody,new BindableProxy(leftUpperLegDisplay),null,null,true,castRig.waistBody));
				_physicsBinders.push(new RigidBodyBinder(castRig.rightUpperLegBody,new BindableProxy(rightUpperLegDisplay),null,null,true,castRig.waistBody));
				_physicsBinders.push(new RigidBodyBinder(castRig.leftLowerLegBody,new BindableProxy(leftLowerLegDisplay),null,null,true,castRig.waistBody));
				_physicsBinders.push(new RigidBodyBinder(castRig.rightLowerLegBody,new BindableProxy(rightLowerLegDisplay),null,null,true,castRig.waistBody));
				
				/*headDisplay.cacheAsBitmap = 
				torso1Display.cacheAsBitmap = 
				torso2Display.cacheAsBitmap = 
				torso3Display.cacheAsBitmap = 
				leftUpperArmDisplay.cacheAsBitmap = 
				rightUpperArmDisplay.cacheAsBitmap = 
				leftLowerArmDisplay.cacheAsBitmap = 
				rightLowerArmDisplay.cacheAsBitmap = 
				leftUpperLegDisplay.cacheAsBitmap = 
				rightUpperLegDisplay.cacheAsBitmap = 
				leftLowerLegDisplay.cacheAsBitmap = 
				rightLowerLegDisplay.cacheAsBitmap = true;*/
				
				childContainer.addChild(avatarDisplay);
			}
			return _physicsBinders;
		}
		public function destroy(parent:DisplayObjectContainer):void{
			parent.removeChild(avatarDisplay);
		}
	}
}