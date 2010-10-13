package org.tbyrne.display.parallax
{
	import org.tbyrne.display.parallax.events.ParallaxEvent;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;

	public class ParallaxSprite extends Sprite implements ILayeredParallaxDisplay
	{
		public function get parallaxChildren():Array{
			return _parallaxChildren;
		}
		public function set parallaxParent(value:IParallaxDisplay):void{
			if(_parallaxParent!=value){
				_parallaxParent = value;
			}
		}
		public function get parallaxParent():IParallaxDisplay{
			return _parallaxParent;
		}
		public function set position(value:Point3D):void{
			if(_position!=value){
				var oldPos:Point3D = _position;
				if (oldPos)
				{
					oldPos.removeEventListener(ParallaxEvent.POSITION_CHANGED, this.handlePositionChange);
				}
				_position = value;
				this.position.addEventListener(ParallaxEvent.POSITION_CHANGED, this.handlePositionChange);
				
				// Dispatch events
				var oldX: Number = NaN;
				var oldY: Number = NaN;
				var oldZ: Number = NaN;
				if (oldPos != null)
				{
					oldX = oldPos.x;
					oldY = oldPos.y;
					oldZ = oldPos.z;
				}
				this.dispatchEventsForPosition((oldPos != null), oldX, oldY, oldZ);
			}
		}
		public function get position():Point3D{
			return _position;
		}
		
		public function get display():DisplayObject{
			return this;
		}
		public function set display(value:DisplayObject):void{
			if(_display!=value){
				if(_display){
					removeChild(_display);
				}
				_display = value;
				if(_display){
					addChild(_display);
				}
			}
		}
		public function set cameraDepth(value:Number):void{
			if(_cameraDepth!=value){
				_cameraDepth = value;
			}
		}
		public function get cameraDepth():Number{
			return _cameraDepth;
		}
		override public function set cacheAsBitmap(value:Boolean):void{
			if(_cacheAsBitmap!=value){
				_cacheAsBitmap = value;
				assessCacheAsBitmap();
			}
		}
		override public function get cacheAsBitmap():Boolean{
			return _cacheAsBitmap;
		}
		override public function set visible(value:Boolean):void{
			super.visible = value;
			assessCacheAsBitmap();
		}
		override public function get visible():Boolean{
			return super.visible;
		}
		public function get useLayer():Boolean{
			return _useLayer;
		}
		public function set useLayer(value:Boolean):void{
			_useLayer = value;
		}
		
		private var _display:DisplayObject;
		private var _position:Point3D;
		private var _parallaxChildren:Array = [];
		private var _parallaxParent:IParallaxDisplay;
		private var _cameraDepth:Number;
		protected var _useLayer:Boolean = false;
		
		private var _cacheAsBitmap:Boolean = false;
		private var _addedToStage:Boolean = false;
		
		public function ParallaxSprite(){
			super();
			position = Point3D.getNew();
			
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			this.addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		}
		private function onAddedToStage(e:Event):void{
			_addedToStage = true;
			assessCacheAsBitmap();
		}
		private function onRemovedFromStage(e:Event):void{
			_addedToStage = false;
			assessCacheAsBitmap();
		}
		
		private function handlePositionChange(event: ParallaxEvent): void
		{
			this.dispatchEventsForPosition(true, event.previousX, event.previousY, event.previousZ);
		}
		
		private function dispatchEventsForPosition(hasPrevious: Boolean, prevX: Number = NaN, 
			prevY: Number = NaN, prevZ: Number = NaN): void
		{
			var event: ParallaxEvent;
			if(!hasPrevious || prevX != this.position.x || prevY != this.position.y){
				event = new ParallaxEvent(ParallaxEvent.POSITION_CHANGED);
				event.previousX = prevX;
				event.previousY = prevY;
				event.previousZ = prevZ;
				this.dispatchEvent(event);
			}
			if (!hasPrevious || prevZ != this.position.z){
				event = new ParallaxEvent(ParallaxEvent.DEPTH_CHANGED);
				event.previousX = prevX;
				event.previousY = prevY;
				event.previousZ = prevZ;
				this.dispatchEvent(event);
			}
		}
		
		public function addParallaxChild(child:IParallaxDisplay):void{
			child.parallaxParent = this;
			_parallaxChildren.push(child);
		}
		public function removeParallaxChild(child:IParallaxDisplay):void{
			if(child.parallaxParent==this){
				var index:Number = _parallaxChildren.indexOf(child);
				_parallaxChildren.splice(index,1);
				child.parallaxParent = null;
			}
		}
		public function removeAllParallaxChildren():void{
			for each(var child:IParallaxDisplay in _parallaxChildren){
				child.parallaxParent = null;
			}
			_parallaxChildren = [];
		}
		
		override public function toString(): String
		{
			return "[ParallaxSprite display:" + name + "]";
		}
		
		protected function assessCacheAsBitmap():void{
			super.cacheAsBitmap = (_cacheAsBitmap && visible && _addedToStage);
		}
	}
}
