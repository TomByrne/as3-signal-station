package org.farmcode.sodalityPlatformEngine.physics.rigs.bicycle
{
	import Box2D.Collision.Shapes.b2CircleDef;
	import Box2D.Collision.Shapes.b2PolygonDef;
	import Box2D.Collision.Shapes.b2ShapeDef;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Joints.b2JointDef;
	import Box2D.Dynamics.Joints.b2PrismaticJointDef;
	import Box2D.Dynamics.Joints.b2RevoluteJoint;
	import Box2D.Dynamics.Joints.b2RevoluteJointDef;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2World;
	
	import org.farmcode.sodalityPlatformEngine.physics.PhysicsUtils;
	import org.farmcode.sodalityPlatformEngine.physics.rigs.Rig;
	
	import flash.geom.Point;

	public class BicycleRig extends Rig
	{
		
		public function set motorSpeed(value:Number):void{
			direction = (value==0?direction:value>0);
			_motorSpeed = value;
			commitSpeed();
			if(value!=0){
				direction = !direction;// this will cause the front wheel to do the braking (looks cool)
			}
		}
		public function get motorSpeed():Number{
			return _motorSpeed;
		}
		public function set maxTorque(value:Number):void{
			_maxTorque = value;
			if(rearMotor){
				rearMotor.SetMaxMotorTorque(_maxTorque*scale);
				frontMotor.SetMaxMotorTorque(_maxTorque*scale);
			}
		}
		public function get maxTorque():Number{
			return _maxTorque;
		}
		
		
		public var direction:Boolean = false;
		public var frontWheelRadius:Number;
		public var backWheelRadius:Number;
		public var frontWheelPosition:Point;
		public var backWheelPosition:Point;
		public var bodyShapes:Array;
		
		public var backWheelBody:b2Body;
		public var frontWheelBody:b2Body;
		public var chassisBody:b2Body;
		public var mainCarBody:b2Body;
		
		private var rearMotor:b2RevoluteJoint;
		private var frontMotor:b2RevoluteJoint;
		private var _motorSpeed:Number;
		private var _maxTorque:Number = 1;
		
		override public function create(world:b2World, x:Number, y:Number, scale:Number):void{
			super.create(world, x, y, scale);
			var jd:b2RevoluteJointDef;
			
			var rigGroupId:Number = -int(Math.random()*1000000);
			
			var backPos:Point = backWheelPosition.add(new Point(x,y));
			var frontPos:Point = frontWheelPosition.add(new Point(x,y));
			
			var midPoint:Point = backPos.add(frontPos);
			midPoint.x /= 2;
			midPoint.y /= 2;
			
			var circle:b2CircleDef = new b2CircleDef();
			circle.filter.groupIndex = rigGroupId;
			circle.density = 0.008;
			circle.restitution = 0.4;
			circle.friction = 17.5;
			circle.radius = backWheelRadius*scale;
			backWheelBody = createBody(world,circle,backPos.x*scale,backPos.y*scale);
			circle.radius = frontWheelRadius*scale;
			frontWheelBody = createBody(world,circle,frontPos.x*scale,frontPos.y*scale);
			
			var chassisData:b2PolygonDef = new b2PolygonDef();
			chassisData.filter.groupIndex = rigGroupId;
			chassisData.density = 0.08;
			chassisData.restitution = 0.4;
			chassisData.friction = 0;
			var chassisHalfWidth: Number = Math.max(frontWheelPosition.x-backWheelPosition.x,20)/2*scale;
			var chassisHalfHeight: Number = Math.max(frontWheelPosition.y-backWheelPosition.y,20)/2*scale;
			chassisData.SetAsBox(chassisHalfWidth, chassisHalfHeight);
			chassisBody = createBody(world,chassisData,midPoint.x*scale,midPoint.y*scale);
			
			jd = new b2RevoluteJointDef();
			jd.body1 = backWheelBody;
			jd.body2 = chassisBody;
			jd.Initialize(backWheelBody,chassisBody,new b2Vec2(backPos.x*scale, backPos.y*scale));
			jd.maxMotorTorque = _maxTorque*scale;
			
			rearMotor = world.CreateJoint(jd) as b2RevoluteJoint;
			
			jd = new b2RevoluteJointDef();
			jd.body1 = frontWheelBody;
			jd.body2 = chassisBody;
			jd.localAnchor1 = new b2Vec2(0,0);
			jd.localAnchor2 = chassisBody.GetLocalPoint(new b2Vec2(frontPos.x*scale, frontPos.y*scale));
			jd.maxMotorTorque = _maxTorque*scale;
			
			frontMotor = world.CreateJoint(jd) as b2RevoluteJoint;
			
			if(bodyShapes)
			{
				// Temp Solution, create chassis and mainBody as one body. 
				// Update this later with joints when can make it play nice
				// Check out revision 1312 for old bicycle rig create code
				// Also will need to change the skin binding; once again see rev 1312
				for each(var shape:b2ShapeDef in bodyShapes)
				{
					shape = PhysicsUtils.scaleShape(shape, scale);
					shape.filter.groupIndex = rigGroupId;
					chassisBody.CreateShape(shape);
				}
				
				/*jd = new b2RevoluteJointDef();
				jd.Initialize(mainCarBody, chassisBody, new b2Vec2(midPoint.x*scale, midPoint.y*scale));
				
				jd.enableLimit = true;
				const MOVE_RANGE_DEG: Number = 0;
				jd.lowerAngle = MOVE_RANGE_DEG*(Math.PI/180);
				jd.upperAngle = -MOVE_RANGE_DEG*(Math.PI/180);
				
				world.CreateJoint(jd);*/
				
				/*var spring:b2DistanceJointDef = new b2DistanceJointDef();
				var chassisAnchor: b2Vec2 = new b2Vec2(midPoint.x*scale, (midPoint.y - 50) * scale);
				var bodyAnchor: b2Vec2 = new b2Vec2((midPoint.x) * scale, (midPoint.y - 200)* scale);
				spring.Initialize(chassisBody, mainCarBody, chassisAnchor, bodyAnchor);
				spring.dampingRatio = 0.5;
				spring.frequencyHz = 5;
				world.CreateJoint(spring);*/
			}
			commitSpeed();
		}
		protected function commitSpeed():void{
			if(!isNaN(_motorSpeed)){
				if(frontMotor){
					if(direction){
						frontMotor.EnableMotor(false);
						rearMotor.EnableMotor(true);
						backWheelBody.WakeUp();
						rearMotor.SetMotorSpeed(-_motorSpeed);
					}else{
						rearMotor.EnableMotor(false);
						frontMotor.EnableMotor(true);
						frontWheelBody.WakeUp();
						frontMotor.SetMotorSpeed(-_motorSpeed);
					}
				}
			}
		}
	}
}