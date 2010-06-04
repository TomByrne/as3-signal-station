package org.farmcode.sodalityPlatformEngine.physics.binders
{
	import Box2D.Collision.Shapes.b2ShapeDef;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2World;
	
	import org.farmcode.sodalityPlatformEngine.physics.PhysicsUtils;
	import org.farmcode.sodalityPlatformEngine.physics.bindables.IPhysicsBindable;
	
	import flash.geom.Point;

	public class ReverseBodyDataBinder extends ReverseBodyBinder
	{
		private var bodyData:b2BodyDef;
		private var shapes:Array = [];
		
		public function ReverseBodyDataBinder(bodyData:b2BodyDef, display:IPhysicsBindable, localOffset:Point=null){
			super(null, display, localOffset);
			this.bodyData = bodyData;
		}
		override public function create(world:b2World, scale:Number):void{
			_body = world.CreateBody(bodyData);
			while(shapes.length){
				var shape:b2ShapeDef = PhysicsUtils.scaleShape(shapes.shift(),scale);
				_body.CreateShape(shape);
			}
			_body.SetMassFromShapes();
			super.create(world, scale);
		}
		public function addShape(shape:b2ShapeDef):void{
			if(_body){
				_body.CreateShape(shape);
			}else{
				shapes.push(shape);
			}
		}
	}
}