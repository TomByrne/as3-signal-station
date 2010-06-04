package org.farmcode.sodalityPlatformEngine.physics.rigs
{
	import Box2D.Collision.Shapes.b2ShapeDef;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Common.Math.b2XForm;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2World;

	public class Rig implements IRig
	{
		protected var joints:Array = [];
		protected var bodies:Array = [];
		protected var scale:Number = 1;
		
		public function create(world:b2World, x:Number, y:Number, scale:Number):void{
			this.scale = scale;
		}
		public function destroy(world:b2World):void{
		}
		protected function createBody(world:b2World, data:b2ShapeDef, x:Number, y:Number, rotation:Number=0):b2Body{
			var bd:b2BodyDef = new b2BodyDef();
			var rb:b2Body = world.CreateBody(bd);
			rb.CreateShape(data);
			rb.SetMassFromShapes();
			rb.SetXForm(new b2Vec2(x,y),rotation);
			bodies.push(rb);
			return rb;
		}
		public function shiftPos(x:Number, y:Number):void{
			for each(var body:b2Body in bodies){
				var xForm:b2XForm = body.GetXForm();
				body.SetXForm(new b2Vec2(xForm.position.x+x*scale,xForm.position.y+y*scale),body.GetAngle());
				body.SetLinearVelocity(new b2Vec2(0,0));
				body.SetAngularVelocity(0);
			}
		}
		
		/**
		 * Here should be functionality to pose the rig (or supply a timeline of poses, i.e. an animation).
		 * when the animations begin, all bodies' mass should be set to 0 (so they become static bodies).
		 */
	}
}