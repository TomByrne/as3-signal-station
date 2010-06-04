package org.farmcode.sodalityPlatformEngine.physics.rigs.bicycle
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2World;
	
	import org.farmcode.sodalityPlatformEngine.parallax.IParallaxItem;
	import org.farmcode.sodalityPlatformEngine.physics.IPhysicsItem;
	import org.farmcode.sodalityPlatformEngine.physics.bindables.BindableProxy;
	import org.farmcode.sodalityPlatformEngine.physics.bindables.ParallaxBindable;
	import org.farmcode.sodalityPlatformEngine.physics.binders.RigidBodyBinder;
	import org.farmcode.sodalityPlatformEngine.physics.rigs.IRig;
	import org.farmcode.sodalityPlatformEngine.physics.rigs.IRigSkin;
	import org.farmcode.reflection.ReflectionUtils;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Point;

	public class SimpleBicycleSkin implements IRigSkin
	{
		public var backWheelName: String = "backWheel";
		public var frontWheelName: String = "frontWheel";
		public var bodyName: String = "body";
		
		private var _bicycleDisplay:DisplayObjectContainer;
		protected var referenceDisplay: DisplayObjectContainer;
		
		public function set bicycleDisplay(value: DisplayObjectContainer): void
		{
			if (value != this._bicycleDisplay)
			{
				this.referenceDisplay = null;
				this._bicycleDisplay = value;
				if (this.bicycleDisplay)
				{
					var type: Class = ReflectionUtils.getClass(this.bicycleDisplay);
					this.referenceDisplay = new type();
				}
			}
		}
		public function get bicycleDisplay(): DisplayObjectContainer
		{
			return this._bicycleDisplay;
		}
				
		public function create(parent:IPhysicsItem, childContainer:DisplayObjectContainer, rig:IRig, 
			world:b2World, x:Number, y:Number, scale:Number):Array
		{
			var referenceBackWheel: DisplayObject = this.referenceDisplay.getChildByName(this.backWheelName);
			var referenceFrontWheel: DisplayObject = this.referenceDisplay.getChildByName(this.frontWheelName);
			
			var _physicsBinders:Array = [];
			childContainer.addChild(bicycleDisplay);
			var castRig:BicycleRig = (rig as BicycleRig);
			
			var backWheelDisplay:DisplayObject = bicycleDisplay.getChildByName(this.backWheelName);
			castRig.backWheelPosition = new Point(referenceBackWheel.x, referenceBackWheel.y);
			backWheelDisplay.rotation = 0;
			castRig.backWheelRadius = referenceBackWheel.width/2;
			
			var frontWheelDisplay:DisplayObject = bicycleDisplay.getChildByName(this.frontWheelName);
			castRig.frontWheelPosition = new Point(referenceFrontWheel.x, referenceFrontWheel.y);
			frontWheelDisplay.rotation = 0;
			castRig.frontWheelRadius = referenceFrontWheel.width/2;
			
			castRig.create(world, x, y, scale);
			
			if(castRig.mainCarBody){
				var center:b2Vec2 = castRig.mainCarBody.GetLocalPoint(castRig.chassisBody.GetWorldCenter());
				var offset:Point = new Point(-center.x,-center.y);
				
				var binder:RigidBodyBinder = new RigidBodyBinder(castRig.backWheelBody,new BindableProxy(backWheelDisplay),null,offset,true,castRig.chassisBody);
				binder.syncPosition = false;
				_physicsBinders.push(binder);
				
				binder = new RigidBodyBinder(castRig.frontWheelBody,new BindableProxy(frontWheelDisplay),null,offset,true,castRig.chassisBody);
				binder.syncPosition = false;
				_physicsBinders.push(binder);
				
				_physicsBinders.push(new RigidBodyBinder(castRig.chassisBody,new ParallaxBindable((parent as IParallaxItem).parallaxDisplay),new Point(center.x,center.y),null,true));
				
				var bodyDisplay:DisplayObject = bicycleDisplay.getChildByName(this.bodyName);
				if(bodyDisplay){
					var center2:b2Vec2 = castRig.mainCarBody.GetLocalCenter();
					binder = new RigidBodyBinder(castRig.mainCarBody,new BindableProxy(bodyDisplay),new Point(center2.x,center2.y),offset,true,castRig.chassisBody);
					//binder.syncPosition = false;
					_physicsBinders.push(binder);
				}
			}else{
				var offsetY:Number = (referenceBackWheel.y+referenceFrontWheel.y)/2;
				_physicsBinders.push(new RigidBodyBinder(castRig.backWheelBody,new BindableProxy(backWheelDisplay),null,new Point(0, -offsetY * scale), false,castRig.chassisBody));
				_physicsBinders.push(new RigidBodyBinder(castRig.frontWheelBody,new BindableProxy(frontWheelDisplay),null,new Point(0, -offsetY * scale), false,castRig.chassisBody));
				_physicsBinders.push(new RigidBodyBinder(castRig.chassisBody,new ParallaxBindable((parent as IParallaxItem).parallaxDisplay), new Point(0, offsetY * scale), null, false));
				
				/*var joinedBodyDisplay:DisplayObject = bicycleDisplay.getChildByName("body");
				if(joinedBodyDisplay){
					_physicsBinders.push(new RigidBodyBinder(castRig.chassisBody,
						new BindableProxy(joinedBodyDisplay),	null,null,true));
				}*/
			}
			
			return _physicsBinders;
		}
		
		public function destroy(parent:DisplayObjectContainer):void{
			parent.removeChild(bicycleDisplay);
		}
		
	}
}