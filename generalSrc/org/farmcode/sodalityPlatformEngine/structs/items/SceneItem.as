package org.farmcode.sodalityPlatformEngine.structs.items
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2World;
	
	import au.com.thefarmdigital.parallax.IParallaxDisplay;
	import au.com.thefarmdigital.parallax.ParallaxDisplay;
	import au.com.thefarmdigital.parallax.Point3D;
	import au.com.thefarmdigital.parallax.events.ParallaxEvent;
	
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.farmcode.sodality.advice.IAdvice;
	import org.farmcode.sodality.advisors.DynamicAdvisor;
	import org.farmcode.sodality.advisors.INonVisualAdvisor;
	import org.farmcode.sodalityPlatformEngine.parallax.IParallaxItem;
	import org.farmcode.sodalityPlatformEngine.physics.IPhysicsItem;
	import org.farmcode.sodalityPlatformEngine.physics.binders.IPhysicsBinder;
	import org.farmcode.sodalityPlatformEngine.scene.IScene;
	import org.farmcode.sodalityPlatformEngine.scene.ISceneItem;

	public class SceneItem extends EventDispatcher implements ISceneItem, IParallaxItem, IPhysicsItem, INonVisualAdvisor
	{
		public function get parallaxDisplay():IParallaxDisplay{
			return _parallaxDisplay;
		}
		public function get dragDisplay():InteractiveObject{
			return null;
		}
		public function get cullBounds():Rectangle{
			return _cullBounds;
		}
		public function set cullBounds(value:Rectangle):void{
			//if(value!=_cullDistance){
				_cullBounds = value;
			//}
		}
		public function get position3D():Point3D{
			return _parallaxDisplay.position;
		}
		public function set position3D(value:Point3D):void{
			if(value){
				var shiftX:Number = value.x;
				var shiftY:Number = value.y;
				if(_parallaxDisplay.position){
					shiftX -= _parallaxDisplay.position.x;
					shiftY -= _parallaxDisplay.position.y;
				}
				shiftPhysics(new Point(shiftX,shiftY));
			}
			_parallaxDisplay.position = value;
		}
		
		// IFocusOffsetItem implementation
		public function get focusX(): Number{
			return _parallaxDisplay.position.x;
		}
		public function get focusY(): Number{
			return _parallaxDisplay.position.y;
		}
		public function get focusRatio(): Number{
			return 1;
		}
		public function get relative(): Boolean{
			return false;
		}
		
		public function get rotation():Number{
			return _parallaxDisplay.display.rotation;
		}
		public function set rotation(value:Number):void{
			_parallaxDisplay.display.rotation = value;
		}
		public function get addToPhysics():Boolean{
			return bindings.length>0;
		}
		public function get scene():IScene{
			return _scene;
		}
		public function set scene(value:IScene):void{
			_scene = value;
		}
		public function get id():String{
			return _id;
		}
		public function set id(value:String):void{
			_id = value;
		}
		public function get useLayer():Boolean{
			return _parallaxDisplay.useLayer;
		}
		public function set useLayer(value:Boolean):void{
			_parallaxDisplay.useLayer = value;
		}
		
		// these co-ord getters/setters are here for initialisation only, please use position3D normally
		public function get x():Number{
			return position3D.x;
		}
		public function set x(value:Number):void{
			position3D.x = value;
		}
		public function get y():Number{
			return position3D.y;
		}
		public function set y(value:Number):void{
			position3D.y = value;
		}
		public function get z():Number{
			return position3D.z;
		}
		public function set z(value:Number):void{
			position3D.z = value;
		}
		protected function get isAdvisor():Boolean{
			return _isAdvisor;
		}
		protected function set isAdvisor(value: Boolean): void
		{
			if (value != this.isAdvisor){
				this._isAdvisor = value;
				assessAdvisor();
			}
		}
		
		public function set advisorDisplay(value:DisplayObject):void{
			this._dynamicAdvisor.advisorDisplay = value;
		}
		public function get advisorDisplay():DisplayObject{
			return this._dynamicAdvisor.advisorDisplay;
		}
		
		public function set addedToPresident(value:Boolean):void{
			this._dynamicAdvisor.addedToPresident = value;
		}
		public function get addedToPresident():Boolean{
			return this._dynamicAdvisor.addedToPresident;
		}
		
		protected var _id:String;
		protected var currentWorld:b2World;
		public var bindings:Array = [];
		
		protected var _parallaxDisplay:ParallaxDisplay;
		protected var _parallaxScale:Number;
		protected var _cullBounds:Rectangle;
		protected var _scene:IScene;
		protected var _isAdvisor:Boolean;
		protected var _dynamicAdvisor:DynamicAdvisor;
		
		protected var _scale:Number;
		
		public function SceneItem(isAdvisor: Boolean = false){
			super();
			_parallaxDisplay = new ParallaxDisplay();
			_parallaxDisplay.cacheAsBitmap = false;
			_parallaxDisplay.addEventListener(ParallaxEvent.DISPLAY_CHANGED, onDisplayChanged);
			_parallaxDisplay.position = new Point3D();
			
			this.isAdvisor = isAdvisor;
		}
		protected function onDisplayChanged(e:Event):void{
			assessAdvisor();
		}
		public function createPhysics(world:b2World, scale:Number):void{
			currentWorld = world;
			_scale = scale;
			for(var i:int=0; i<bindings.length; ++i){
				var binder:IPhysicsBinder = bindings[i];
				binder.create(world, scale);
			}
		}
		public function stepPhysics():void{
			if(currentWorld){
				for(var i:int=0; i<bindings.length; ++i){
					var binder:IPhysicsBinder = bindings[i];
					binder.step(currentWorld);
				}
			}
		}
		public function destroyPhysics(world:b2World):void{
			currentWorld = null;
			for(var i:int=0; i<bindings.length; ++i){
				var binder:IPhysicsBinder = bindings[i];
				binder.destroy(world);
			}
			bindings = [];
		}
		protected function shiftPhysics(shift:Point):void{
			for each(var binding:IPhysicsBinder in bindings){
				binding.shift(shift.x*_scale,shift.y*_scale);
			}
		}
		public function applyImpulse(impulse:Point):void{
			var _impulse:b2Vec2 = new b2Vec2(impulse.x,impulse.y);
			for each(var binding:IPhysicsBinder in bindings){
				binding.body.ApplyImpulse(_impulse,binding.body.GetWorldCenter());
			}
			if(!bindings || !bindings.length){
				bindings = bindings;
			}
		}
		
		protected function addBinding(binding:IPhysicsBinder):void{
			var index:Number = bindings.indexOf(binding);
			if(index==-1){
				bindings.push(binding);
				if(currentWorld)binding.create(currentWorld, _scale);
			}
		}
		protected function removeBinding(binding:IPhysicsBinder):void{
			var index:Number = bindings.indexOf(binding);
			if(index!=-1){
				if(currentWorld)binding.destroy(currentWorld);
				bindings.splice(index,1);
			}
		}
		protected function assessAdvisor():void{
			if (this.isAdvisor){
				if(!_dynamicAdvisor){
					_dynamicAdvisor = new DynamicAdvisor(null,this);
				}
				_dynamicAdvisor.advisorDisplay = _parallaxDisplay.display;
			}else if(_dynamicAdvisor){
				_dynamicAdvisor.advisorDisplay = null;
			}
		}
		public function triggerPosChangeEvent():void{
			_parallaxDisplay.dispatchEvent(new ParallaxEvent(ParallaxEvent.POSITION_CHANGED));
		}
		public function triggerDepthChangeEvent():void{
			_parallaxDisplay.dispatchEvent(new ParallaxEvent(ParallaxEvent.POSITION_CHANGED));
		}
		
		override public function dispatchEvent(event: Event): Boolean
		{
			if (event is IAdvice)
			{
				if (this.isAdvisor)
				{
					if (!this.addedToPresident)
					{
						trace("WARNING: Trying to dispatch advice from SceneItem while not added to president: " + event);
					}
				}
				else
				{
					trace("WARNING: Trying to dispatch advice from SceneItem not set up as advisor: " + event);
				}
			}
			
			return super.dispatchEvent(event);
		}
	}
}
