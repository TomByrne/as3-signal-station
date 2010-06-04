package org.farmcode.sodalityPlatformEngine.physics.items
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Joints.b2MouseJoint;
	import Box2D.Dynamics.Joints.b2MouseJointDef;
	import Box2D.Dynamics.b2World;
	
	import au.com.thefarmdigital.utils.DisplayUtils;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import org.farmcode.sodalityPlatformEngine.physics.binders.IPhysicsBinder;
	import org.farmcode.sodalityPlatformEngine.structs.items.SceneItem;
	
	public class DraggableItem extends SceneItem
	{
		public function get draggable():Boolean{
			return _draggable;
		}
		public function set draggable(value:Boolean):void{
			if(_draggable!=value){
				_draggable = value;
				if(!_draggable){
					onMouseRelease();
				}
			}
			assessDraggable();
		}
		public function get dragging():Boolean{
			return _dragging;
		}
		public function set dragging(value:Boolean):void{
			_dragging = value;
		}
		public function set addToPhysics(value:Boolean):void{
			_addToPhysics = value;
		}
		override public function get addToPhysics():Boolean{
			return _addToPhysics;
		}
		
		protected var _addToPhysics:Boolean = true;
		protected var _draggable:Boolean;
		protected var _dragging:Boolean;
		protected var joint:b2MouseJoint;
		protected var lastStage:Stage;
		
		public function DraggableItem(isAdvisor: Boolean = false){
			super(isAdvisor);
			this.draggable = false;
		}
		override protected function onDisplayChanged(e:Event) : void{
			super.onDisplayChanged(e);
			assessDraggable();
		}
		protected function onMouseDown(e:MouseEvent):void{
			if(_draggable){
				_parallaxDisplay.display.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseRelease);
				lastStage = _parallaxDisplay.display.stage;
				
				var binder:IPhysicsBinder = getBinderAtPoint(_parallaxDisplay.display.stage.mouseX, _parallaxDisplay.display.stage.mouseY);
				var mouseJoint:b2MouseJointDef = new b2MouseJointDef();
				mouseJoint.body1 = currentWorld.GetGroundBody();
				mouseJoint.body2 = binder.body;
				mouseJoint.target = getPhysicsMousePoint();
				mouseJoint.maxForce = 30000000000000.0 * binder.body.GetMass();
				mouseJoint.frequencyHz = 25;
				mouseJoint.dampingRatio = 1;
				joint = currentWorld.CreateJoint(mouseJoint) as b2MouseJoint;
				dragging = true;
			}
		}
		protected function onMouseRelease(e:MouseEvent=null):void{
			if(joint){
				lastStage.removeEventListener(MouseEvent.MOUSE_UP, onMouseRelease);
				lastStage = null;
				currentWorld.DestroyJoint(joint);
				joint = null
				dragging = false;
			}
		}
		protected function getPhysicsMousePoint():b2Vec2{
			var mousePoint:Point = _parallaxDisplay.display.localToGlobal(new Point(_parallaxDisplay.display.mouseX,_parallaxDisplay.display.mouseY));
			var selfPoint:Point = _parallaxDisplay.display.localToGlobal(new Point(0,0));
			return new b2Vec2((_parallaxDisplay.position.x+(mousePoint.x-selfPoint.x))*_scale,(_parallaxDisplay.position.y+(mousePoint.y-selfPoint.y))*_scale)
		}
		override public function stepPhysics():void{
			super.stepPhysics();
			if(joint){
				joint.SetTarget(getPhysicsMousePoint());
			}
		}
		override public function destroyPhysics(world:b2World):void{
			super.destroyPhysics(world);
			onMouseRelease();
		}
		protected function getBinderAtPoint(x:Number, y:Number):IPhysicsBinder{
			var ret:IPhysicsBinder;
			var def:IPhysicsBinder;
			for(var i:int=0; i<bindings.length; ++i){
				var binding:IPhysicsBinder = bindings[i];
				var desc:Boolean = true;
				if(ret){
					var cast:DisplayObjectContainer = ret.display as DisplayObjectContainer;
					desc = (cast && DisplayUtils.isDescendant(cast,binding.display));
				}
				if(binding.display.hitTestPoint(x,y,true) && desc){
					ret = binding;
				}
				if(!def){
					def = ret;
				}
			}
			return ret?ret:def;
		}
		protected function assessDraggable():void{
			var display:Sprite = _parallaxDisplay.display as Sprite;
			if(display){
				display.buttonMode = this.draggable;
				display.mouseEnabled = this.draggable;
				if(draggable){
					display.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				}else{
					display.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				}
			}
		}
	}
}