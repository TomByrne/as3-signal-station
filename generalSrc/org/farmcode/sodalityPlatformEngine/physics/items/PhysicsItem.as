package org.farmcode.sodalityPlatformEngine.physics.items
{
	import Box2D.Collision.b2ContactPoint;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2World;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	import org.farmcode.sodality.events.AdvisorEvent;
	import org.farmcode.sodalityPlatformEngine.physics.advice.AddContactListenerAdvice;
	import org.farmcode.sodalityPlatformEngine.physics.advice.RemoveContactListenerAdvice;
	import org.farmcode.sodalityPlatformEngine.physics.bindables.ParallaxBindable;
	import org.farmcode.sodalityPlatformEngine.physics.binders.IPhysicsBinder;
	import org.farmcode.sodalityPlatformEngine.physics.binders.RigidBodyDataBinder;
	
	public class PhysicsItem extends DraggableItem
	{
		public function get shapeData():Array{
			return _shapeData;
		}
		public function set shapeData(value:Array):void{
			if(_shapeData != value){
				if(_shapeBinder){
					removeBinding(_shapeBinder);
					_shapeBinder = null;
				}
				_shapeData = value;
				if(_shapeData){
					var bodyData:b2BodyDef = new b2BodyDef();
					_shapeBinder = new RigidBodyDataBinder(bodyData,new ParallaxBindable(parallaxDisplay),null);
					for(var i:int=0; i<_shapeData.length; ++i){
						_shapeBinder.addShape(_shapeData[i]);
					}
				}
			}
		}
		
		[Property(toString="true",clonable="true")]
		public function get contactListening():Boolean{
			return _contactListening;
		}
		public function set contactListening(value:Boolean):void{
			if(_contactListening != value){
				_contactListening = value;
				isAdvisor = value;
				checkContactListener();
			}
		}
		
		
		private var _contactListening:Boolean;
		private var _actuallyListening:Boolean;
		protected var _shapeData:Array;
		protected var _shapeBinder:RigidBodyDataBinder;
		
		public function PhysicsItem(){
			this.addEventListener(AdvisorEvent.ADVISOR_ADDED, onAdvisorAdded);
			_parallaxDisplay.display = new Sprite();
		}
		protected function onAdvisorAdded(e:Event):void{
			checkContactListener();
		}
		override public function createPhysics(world:b2World, scale:Number):void{
			super.createPhysics(world, scale);
			addBinding(_shapeBinder);
			checkContactListener();
		}
		protected function checkContactListener():void{
			if(_contactListening && _parallaxDisplay.display.stage && currentWorld){
				if(!_actuallyListening){
					_actuallyListening = true;
					var bodies:Array = [];
					for each(var binding:IPhysicsBinder in bindings){
						bodies.push(binding.body);
					}
					dispatchEvent(new AddContactListenerAdvice(contactEvent,bodies));
				}
			}else if(_actuallyListening){
				_actuallyListening = false;
				dispatchEvent(new RemoveContactListenerAdvice(contactEvent,bodies));
			}
		}
		protected function contactEvent(event:String, point:b2ContactPoint):void{
		}
		protected function setAngularVelocity(omega:Number):void{
			for each(var binding:IPhysicsBinder in bindings){
				binding.body.SetAngularVelocity(omega);
			}
		}
	}
}