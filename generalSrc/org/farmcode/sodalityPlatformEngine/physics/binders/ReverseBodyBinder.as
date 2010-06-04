package org.farmcode.sodalityPlatformEngine.physics.binders
{
	import Box2D.Collision.Shapes.b2MassData;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Common.b2internal;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2World;
	
	use namespace Box2D.Common.b2internal;
	
	import org.farmcode.sodalityPlatformEngine.physics.bindables.IPhysicsBindable;
	
	import flash.display.DisplayObject;
	import flash.geom.Point;
	import org.farmcode.math.Trigonometry;
	
	public class ReverseBodyBinder implements IPhysicsBinder
	{
		public function get body():b2Body{
			return _body;
		}
		public function get display():DisplayObject{
			return _display.display;
		}
		
		protected var _body:b2Body;
		protected var _display:IPhysicsBindable;
		protected var localOffset:Point;
		
		protected var _scale:Number = 1;
		
		public var syncPosition:Boolean = true;
		public var syncRotation:Boolean = true;
		
		public function ReverseBodyBinder(body:b2Body, display:IPhysicsBindable, localOffset:Point=null){
			this._body = body;
			this._display = display;
			this.localOffset = localOffset;
		}
		public function create(world:b2World, scale:Number):void{
			_scale = scale;
			setBodyPos(world);
			var massData:b2MassData = new b2MassData();
			massData.mass = 0;
			_body.SetMass(massData);
		}
		public function step(world:b2World):void{
			setBodyPos(world);
		}
		protected function setBodyPos(world:b2World):void{
			var offset:Point = getOffset(_display.rotation*(Math.PI/180));
			var pos:b2Vec2 = new b2Vec2((_display.x*_scale)+offset.x,(_display.y*_scale)+offset.y);
			pos.x = Math.max(Math.min(pos.x,world.m_broadPhase.m_worldAABB.upperBound.x),world.m_broadPhase.m_worldAABB.lowerBound.x);
			pos.y = Math.max(Math.min(pos.y,world.m_broadPhase.m_worldAABB.upperBound.y),world.m_broadPhase.m_worldAABB.lowerBound.y);
			_body.SetXForm(pos,_display.rotation*(Math.PI/180));
		}
		public function destroy(world:b2World):void{
			if(_body){
				world.DestroyBody(_body);
				_body = null;
			}
		}
		protected function getOffset(rotation:Number):Point{
			var ret:Point = new Point();
			if(localOffset){
				var angle:Number = Trigonometry.getDirection(new Point(),localOffset);
				var dist:Number = Trigonometry.getDistance(new Point(),localOffset);
				ret = ret.add(Trigonometry.projectPoint(dist,angle+(rotation*180/Math.PI),new Point()));
			}
			return ret;
		}
		public function shift(x:Number, y:Number):void{
			_display.x += x;
			_display.y += y;
		}
	}
}