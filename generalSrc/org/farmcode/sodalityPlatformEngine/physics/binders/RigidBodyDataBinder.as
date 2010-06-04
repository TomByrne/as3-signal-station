package org.farmcode.sodalityPlatformEngine.physics.binders
{
	import Box2D.Collision.Shapes.b2Shape;
	import Box2D.Collision.Shapes.b2ShapeDef;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2World;
	
	import org.farmcode.sodalityPlatformEngine.physics.PhysicsUtils;
	import org.farmcode.sodalityPlatformEngine.physics.bindables.IPhysicsBindable;
	
	import flash.geom.Point;

	public class RigidBodyDataBinder extends RigidBodyBinder
	{
		public var bodyData:b2BodyDef;
		private var shapes:Array = [];
		
		public function RigidBodyDataBinder(bodyData:b2BodyDef, display:IPhysicsBindable, localOffset:Point=null, globalOffset:Point=null){
			super(null, display, localOffset, globalOffset);
			this.bodyData = bodyData;
		}
		override public function create(world:b2World, scale:Number):void{
			_body = world.CreateBody(bodyData);
			for each(var shapeDef:b2ShapeDef in shapes){
				shapeDef = PhysicsUtils.scaleShape(shapeDef,scale);
				var shape:b2Shape = _body.CreateShape(shapeDef);
			}
			_body.SetMassFromShapes();
			super.create(world, scale);
		}
		public function addShape(shape:b2ShapeDef):void{
			if(_body){
				_body.CreateShape(shape);
				_body.SetMassFromShapes();
			}
			shapes.push(shape);
		}
	}
}