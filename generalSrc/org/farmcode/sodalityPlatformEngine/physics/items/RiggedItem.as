package org.farmcode.sodalityPlatformEngine.physics.items
{
	import Box2D.Dynamics.b2World;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	
	import org.farmcode.sodalityPlatformEngine.physics.binders.IPhysicsBinder;
	import org.farmcode.sodalityPlatformEngine.physics.rigs.IRig;
	import org.farmcode.sodalityPlatformEngine.physics.rigs.IRigSkin;
	
	public class RiggedItem extends DraggableItem
	{
		public function get rig():IRig{
			return _rig;
		}
		public function set rig(value:IRig):void{
			if(value!=_rig){
				_rig = value;
			}
		}
		public function get rigSkin():IRigSkin{
			return _rigSkin;
		}
		public function set rigSkin(value:IRigSkin):void{
			if(value!=_rigSkin){
				_rigSkin = value;
			}
		}
		override public function get addToPhysics():Boolean{
			return true;
		}
		
		private var _rig:IRig
		private var _rigSkin:IRigSkin;
		private var _created:Boolean;
		private var _displayContainer:DisplayObjectContainer;
		
		public function RiggedItem(isAdvisor: Boolean = false)
		{
			super(isAdvisor);
			_parallaxDisplay.display = _displayContainer = new Sprite();
		}
		
		override public function createPhysics(world:b2World, scale:Number):void{
			if(!_created){
				currentWorld = world;
				_scale = scale;
				recreatePhysics();
			}
		}
		protected function recreatePhysics():void{
			if(currentWorld){
				var world:b2World = currentWorld;
				destroyPhysics(currentWorld);
				currentWorld = world;
				if(_rigSkin && _rig)
				{
					var bindings:Array = _rigSkin.create(this, _displayContainer, _rig, currentWorld, parallaxDisplay.position.x, parallaxDisplay.position.y, _scale);
					for each(var binding:IPhysicsBinder in bindings)
					{
						addBinding(binding);
					}
				}
				super.createPhysics(currentWorld, _scale);
				_created = true;
			}
		}
		override public function destroyPhysics(world:b2World):void{
			if(_created){
				_created = false;
				super.destroyPhysics(world);
				_rig.destroy(world);
			}
		}
	}
}