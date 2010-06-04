package org.farmcode.sodalityPlatformEngine.physics.binders
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Common.Math.b2XForm;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2World;
	
	import org.farmcode.sodalityPlatformEngine.physics.bindables.IPhysicsBindable;
	
	import flash.display.DisplayObject;
	import flash.geom.Point;
	
	import org.farmcode.math.Trigonometry;
	
	public class RigidBodyBinder implements IPhysicsBinder
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
		protected var globalOffset:Point;
		protected var startAtDisplay:Boolean;
		
		protected var _scale:Number = 1;
		
		public var syncPosition:Boolean = true;
		public var syncRotation:Boolean = true;
		
		public var parentBody:b2Body;
		
		public function RigidBodyBinder(body:b2Body, display:IPhysicsBindable, localOffset:Point=null, 
			globalOffset:Point=null, startAtDisplay:Boolean=true, parentBody:b2Body=null)
		{
			this._body = body;
			this._display = display;
			this.localOffset = localOffset;
			this.globalOffset = globalOffset;
			this.parentBody = parentBody;
			this.startAtDisplay= startAtDisplay;
		}
		public function create(world:b2World, scale:Number):void{
			_scale = scale;
			var xForm:b2XForm = _body.GetXForm();
			if(startAtDisplay){
				if(syncPosition){
					var offset:Point = getOffset(_display.rotation*(Math.PI/180));
					xForm.position.x = (_display.x*_scale)+offset.x;
					xForm.position.y = (_display.y*_scale)+offset.y;
				}
				if(syncRotation){
					_body.SetXForm(xForm.position,_display.rotation*(Math.PI/180));
				}else{
					_body.SetXForm(xForm.position,_body.GetAngle());
				}
			}else{
				if(syncPosition){
					offset = getOffset(_body.GetAngle());
					_display.x = (xForm.position.x-offset.x)/_scale;
					_display.y = (xForm.position.y-offset.y)/_scale;
				}
				if(syncRotation){
					_display.rotation = _body.GetAngle()*(180/Math.PI);
				}
			}
		}
		public function step(world:b2World):void{
			if(parentBody){
				if(syncPosition){
					var offset:Point = getOffset(_body.GetAngle()-parentBody.GetAngle());
					var pos:b2Vec2 = parentBody.GetLocalPoint(_body.GetWorldCenter());
					_display.x = (pos.x-offset.x)/_scale;
					_display.y = (pos.y-offset.y)/_scale;
				}
				if(syncRotation)_display.rotation = (_body.GetAngle()-parentBody.GetAngle())*(180/Math.PI);
			}else{
				if(syncPosition){
					offset = getOffset(_body.GetAngle());
					_display.x = (_body.GetPosition().x-offset.x)/_scale;
					_display.y = (_body.GetPosition().y-offset.y)/_scale;
				}
				if(syncRotation)_display.rotation = _body.GetAngle()*(180/Math.PI);
			}
		}
		public function destroy(world:b2World):void{
			if(_body){
				world.DestroyBody(_body);
				_body = null;
			}
		}
		protected function getOffset(rotation:Number):Point{
			var ret:Point = new Point();
			if(globalOffset){
				ret.x += globalOffset.x;
				ret.y += globalOffset.y;
			}
			if(localOffset){
				var angle:Number = Trigonometry.getDirection(new Point(),localOffset);
				var dist:Number = Trigonometry.getDistance(new Point(),localOffset);
				ret = ret.add(Trigonometry.projectPoint(dist,angle+(rotation*180/Math.PI),new Point()));
			}
			return ret;
		}
		public function shift(x:Number, y:Number):void{
			if(syncPosition){
				var current:b2XForm = body.GetXForm();
				var oldX: Number= current.position.x;
				var oldY: Number= current.position.y;
				body.SetXForm(new b2Vec2(current.position.x+x,current.position.y+y),0);
				body.SetLinearVelocity(new b2Vec2());
			}
		}
	}
}