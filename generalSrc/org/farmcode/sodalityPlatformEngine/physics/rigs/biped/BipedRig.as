package org.farmcode.sodalityPlatformEngine.physics.rigs.biped
{
	import Box2D.Collision.Shapes.b2CircleDef;
	import Box2D.Collision.Shapes.b2PolygonDef;
	import Box2D.Collision.Shapes.b2ShapeDef;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Joints.b2RevoluteJointDef;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2World;
	
	import org.farmcode.sodalityPlatformEngine.physics.rigs.Rig;

	public class BipedRig extends Rig
	{
		
		public var headRadius:Number;
		public var shoulderWidth:Number;
		public var shoulderHeight:Number;
		public var waistWidth:Number;
		public var waistHeight:Number;
		public var hipWidth:Number;
		public var hipHeight:Number;
		public var upperArmLength:Number;
		public var upperArmWidth:Number;
		public var lowerArmLength:Number;
		public var lowerArmWidth:Number;
		public var upperLegLength:Number;
		public var upperLegWidth:Number;
		public var lowerLegLength:Number;
		public var lowerLegWidth:Number;
		
		public var headBody:b2Body;
		public var shoulderBody:b2Body;
		public var waistBody:b2Body;
		public var hipBody:b2Body;
		
		public var rightUpperArmBody:b2Body;
		public var leftUpperArmBody:b2Body;
		public var rightLowerArmBody:b2Body;
		public var leftLowerArmBody:b2Body;
		
		public var rightUpperLegBody:b2Body;
		public var leftUpperLegBody:b2Body;
		public var rightLowerLegBody:b2Body;
		public var leftLowerLegBody:b2Body;
		
		override public function create(world:b2World, x:Number, y:Number, scale:Number):void{
			super.create(world, x, y, scale);
			var startX:Number = x;
			var startY:Number = y;
			var vStack:Number = startY;
			
			// BODIES
			// Head
			var headShape:b2CircleDef = new b2CircleDef();
			headShape.density = 0.01;
			headShape.radius = headRadius*scale;
			headShape.friction = 0.4;
			headShape.restitution = 0.3;
			headBody = createBody(world, headShape,startX*scale, startY*scale);
			
			vStack += headRadius+shoulderHeight/2;
			
			// Shoulders
			var box:b2PolygonDef = new b2PolygonDef();
			box.density = 0.01;
			box.SetAsBox(shoulderWidth/2*scale, shoulderHeight/2*scale);
			box.friction = 0.4;
			box.restitution = 0.1;
			shoulderBody = createBody(world, box,startX*scale, vStack*scale);
			vStack += (shoulderHeight/2)+(waistHeight/2);
			// Waist
			box.SetAsBox(waistWidth/2*scale, waistHeight/2*scale);
			waistBody = createBody(world,box,startX*scale, vStack*scale);
			vStack += (waistHeight/2)+(hipHeight/2);
			// Hips
			box.SetAsBox(hipWidth/2*scale, hipHeight/2*scale);
			hipBody = createBody(world,box,startX*scale, vStack*scale);
			vStack += (hipHeight/2)+upperLegLength/2;
			
			// UpperArm
			box.SetAsBox(upperArmLength/2*scale, upperArmWidth/2*scale);
			box.friction = 0.4;
			box.restitution = 0.1;
			// L
			var armY:Number = startY+headRadius+upperArmWidth/2;
			rightUpperArmBody = createBody(world,box,(startX-shoulderWidth/2-upperArmLength/2)*scale,armY*scale);
			// R
			leftUpperArmBody = createBody(world,box,(startX+shoulderWidth/2+upperArmLength/2)*scale,armY*scale);
			
			// LowerArm
			box.SetAsBox(lowerArmLength/2*scale, lowerArmWidth/2*scale);
			box.friction = 0.4;
			box.restitution = 0.1;
			// L
			rightLowerArmBody = createBody(world,box,(startX-shoulderWidth/2-upperArmLength-lowerArmLength/2)*scale, armY*scale);
			// R
			leftLowerArmBody = createBody(world,box,(startX+shoulderWidth/2+upperArmLength+lowerArmLength/2)*scale, armY*scale);
			
			// UpperLeg
			box.SetAsBox(upperLegWidth/2*scale, upperLegLength/2*scale);
			box.friction = 0.4;
			box.restitution = 0.1;
			// L
			rightUpperLegBody = createBody(world,box,(startX-hipWidth/2+upperLegWidth/2)*scale, vStack*scale);
			// R
			leftUpperLegBody = createBody(world,box,(startX+hipWidth/2-upperLegWidth/2)*scale, vStack*scale);
			vStack += upperLegLength/2+lowerLegLength/2
			// LowerLeg
			box.SetAsBox(lowerLegWidth/2*scale, lowerLegLength/2*scale);
			box.friction = 0.4;
			box.restitution = 0.1;
			// L
			rightLowerLegBody = createBody(world,box,(startX-hipWidth/2+upperLegWidth/2)*scale, vStack*scale);
			// R
			leftLowerLegBody = createBody(world,box,(startX+hipWidth/2-upperLegWidth/2)*scale, vStack*scale);
			
			
			// JOINTS
			const DEGREES_PER_RADIAN:Number = (Math.PI/180);
			// Head to shoulders
			var jd:b2RevoluteJointDef = new b2RevoluteJointDef();
			jd.enableLimit = true;
			jd.Initialize(shoulderBody,headBody,new b2Vec2(startX*scale, (startY + headRadius)*scale));
			jd.lowerAngle = -40 * DEGREES_PER_RADIAN;
			jd.upperAngle = 40 * DEGREES_PER_RADIAN;
			world.CreateJoint(jd);
			
			// Upper arm to shoulders
			// L
			jd.Initialize(shoulderBody, rightUpperArmBody,new b2Vec2((startX-shoulderWidth/2)*scale, (armY)*scale));
			jd.lowerAngle = -85 * DEGREES_PER_RADIAN;
			jd.upperAngle = 150 * DEGREES_PER_RADIAN;
			world.CreateJoint(jd);
			// 
			jd.Initialize(shoulderBody, leftUpperArmBody,new b2Vec2((startX+shoulderWidth/2)*scale, (armY)*scale));
			jd.lowerAngle = -150 * DEGREES_PER_RADIAN;
			jd.upperAngle = 85 * DEGREES_PER_RADIAN;
			world.CreateJoint(jd);
			
			// Lower arm to upper arm
			// L
			jd.Initialize(rightUpperArmBody, rightLowerArmBody,new b2Vec2((startX-shoulderWidth/2-upperArmLength)*scale, (armY)*scale));
			jd.lowerAngle = -130 * DEGREES_PER_RADIAN;
			jd.upperAngle = 10 * DEGREES_PER_RADIAN;
			world.CreateJoint(jd);
			// R
			jd.Initialize(leftUpperArmBody, leftLowerArmBody,new b2Vec2((startX+shoulderWidth/2+upperArmLength)*scale, (armY)*scale));
			jd.lowerAngle = -10 * DEGREES_PER_RADIAN;
			jd.upperAngle = 130 * DEGREES_PER_RADIAN;
			world.CreateJoint(jd);
			
			// Shoulders/stomach
			jd.Initialize(shoulderBody, waistBody,new b2Vec2((startX)*scale, (startY+headRadius+shoulderHeight)*scale));
			jd.lowerAngle = -15 * DEGREES_PER_RADIAN;
			jd.upperAngle = 15 * DEGREES_PER_RADIAN;
			world.CreateJoint(jd);
			// Stomach/hips
			jd.Initialize(waistBody, hipBody,new b2Vec2((startX)*scale, (startY+headRadius+shoulderHeight+waistHeight)*scale));
			jd.lowerAngle = -15 * DEGREES_PER_RADIAN;
			jd.upperAngle = 15 * DEGREES_PER_RADIAN;
			world.CreateJoint(jd);
			
			var torsoHeight:Number = shoulderHeight+waistHeight+hipHeight;
			// Torso to upper leg
			// L
			jd.Initialize(hipBody, rightUpperLegBody,new b2Vec2((startX-hipWidth/2+upperLegWidth/2)*scale, (startY+headRadius+torsoHeight)*scale));
			jd.lowerAngle = -25 * DEGREES_PER_RADIAN;
			jd.upperAngle = 45 * DEGREES_PER_RADIAN;
			world.CreateJoint(jd);
			// R
			jd.Initialize(hipBody, leftUpperLegBody,new b2Vec2((startX+hipWidth/2-upperLegWidth/2)*scale, (startY+headRadius+torsoHeight)*scale));
			jd.lowerAngle = -45 * DEGREES_PER_RADIAN;
			jd.upperAngle = 25 * DEGREES_PER_RADIAN;
			world.CreateJoint(jd);
			
			// Upper leg to lower leg
			// L
			jd.Initialize(rightUpperLegBody, rightLowerLegBody,new b2Vec2((startX-hipWidth/2+upperLegWidth/2)*scale, (startY+headRadius+torsoHeight+upperLegLength)*scale));
			jd.lowerAngle = -25 * DEGREES_PER_RADIAN;
			jd.upperAngle = 115 * DEGREES_PER_RADIAN;
			world.CreateJoint(jd);
			// R
			jd.Initialize(leftUpperLegBody, leftLowerLegBody,new b2Vec2((startX+hipWidth/2-upperLegWidth/2)*scale, (startY+headRadius+torsoHeight+upperLegLength)*scale));
			jd.lowerAngle = -115 * DEGREES_PER_RADIAN;
			jd.upperAngle = 25 * DEGREES_PER_RADIAN;
			world.CreateJoint(jd);
		}
	}
}