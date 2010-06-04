package au.com.thefarmdigital.parallax
{
	import au.com.thefarmdigital.parallax.depthSorting.CameraDepthSorter;
	import au.com.thefarmdigital.parallax.events.ParallaxEvent;
	import au.com.thefarmdigital.parallax.modifiers.ParallaxCamera;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	public class Parallax extends AbstractParallax
	{
		public function get camera():ParallaxCamera{
			return _camera;
		}
		public function set container(value:DisplayObjectContainer):void{
			if(_outerContainer!=value){
				if(_outerContainer){
					_outerContainer.removeChild(_container);
				}
				_outerContainer = value;
				if(_outerContainer){
					_outerContainer.addChild(_container);
				}
				_allParentInvalid = true;
			}
		}
		public function get container():DisplayObjectContainer{
			return _outerContainer;
		}
		public function set modifiers(value:Array):void{
			if(_explicitModifiers!=value){
				_explicitModifiers = value;
				_modifiers = [_camera].concat(_explicitModifiers);
			}
		}
		public function get modifiers():Array{
			return _explicitModifiers;
		}
		public function get width():Number{
			return scrollRect.width;
		}
		public function set width(value:Number):void{
			if(value!=scrollRect.width){
				scrollRect.width = value;
				scrollRect.x = -value/2;
				assessContainer();
			}
		}
		public function get height():Number{
			return scrollRect.height;
		}
		public function set height(value:Number):void{
			if(value!=scrollRect.height){
				scrollRect.height = value;
				scrollRect.y = -value/2;
				assessContainer()
			}
		}
		public function get doMask():Boolean{
			return _doMask;
		}
		public function set doMask(value:Boolean):void{
			if(value!=_doMask){
				_doMask = value;
			}
		}

		public var autoRender:Boolean = true;
		
		protected var _outerContainer:DisplayObjectContainer;
		protected var _explicitModifiers:Array;
		protected var _camera:ParallaxCamera;
		protected var scrollRect:Rectangle = new Rectangle;
		protected var _doMask:Boolean = true;
		
		protected var _posInvalid:Dictionary = new Dictionary();
		protected var _parentInvalid:Dictionary = new Dictionary();
		
		protected var _allPosInvalid:Boolean = false;
		protected var _allDepthInvalid:Boolean = false;
		protected var _allParentInvalid:Boolean = false;
		
		public function Parallax(){
			_container = new Sprite();
			_depthSorter = new CameraDepthSorter();
			_camera = new ParallaxCamera();
			//_camera.rounding = true; // doesn't seem to increase performance?
			_camera.addEventListener(ParallaxEvent.POSITION_CHANGED,invalidatePosition);
			_camera.addEventListener(ParallaxEvent.DEPTH_CHANGED,invalidateDepth);
			modifiers = [];
		}
		public function addChild(parallaxDisplay:IParallaxDisplay):void{
			_addChild(parallaxDisplay);
			parallaxDisplay.addEventListener(ParallaxEvent.POSITION_CHANGED,onChildPosChange);
			parallaxDisplay.addEventListener(ParallaxEvent.DEPTH_CHANGED,onChildDepthChange);
			//parallaxDisplay.display.addEventListener(Event.REMOVED, onChildParentChange);
			_posInvalid[parallaxDisplay] = true;
			_parentInvalid[parallaxDisplay] = true;
			_allDepthInvalid = true;
		}
		/*public function isChild(parallaxDisplay:IParallaxDisplay):Boolean{
			return childrenDict[parallaxDisplay];
		}*/
		public function removeChild(parallaxDisplay:IParallaxDisplay):void{
			if(childrenDict[parallaxDisplay]){
				_removeChild(parallaxDisplay);
				delete _parentInvalid[parallaxDisplay];
				delete _posInvalid[parallaxDisplay];
				parallaxDisplay.removeEventListener(ParallaxEvent.POSITION_CHANGED,onChildPosChange);
				parallaxDisplay.removeEventListener(ParallaxEvent.DEPTH_CHANGED,onChildDepthChange);
				//parallaxDisplay.display.removeEventListener(Event.REMOVED, onChildParentChange);
			}
		}
		public function removeAllChildren():void{
			/*while(directChildren.length){
				removeChild(directChildren[0]);
			}*/
			for each(var child:IParallaxDisplay in directChildren){
				child.addEventListener(ParallaxEvent.POSITION_CHANGED,onChildPosChange);
				child.addEventListener(ParallaxEvent.DEPTH_CHANGED,onChildDepthChange);
			}
			if(_outerContainer){
				_outerContainer.removeChild(_container);
			}
			_container = new Sprite();
			if(_outerContainer){
				_outerContainer.addChild(_container);
			}
			_posInvalid = new Dictionary();
			_parentInvalid = new Dictionary();
			_allPosInvalid = _allDepthInvalid = _allParentInvalid = false;
			directChildren = [];
			childrenDict = new Dictionary();
			assessContainer();
		}
		public function render():void{
			if(_allParentInvalid && _allPosInvalid && _allDepthInvalid){
				_renderAll();
			}else{
				modifyContainer();
				var child:IParallaxDisplay;
				if(_allParentInvalid || _allPosInvalid){
					for each(child in directChildren){
						if(_allParentInvalid){
							_parentItem(child);
						}
						if(_allPosInvalid){
							_renderItem(child, _modifiers);
						}
					}
				}
				
				// parent invalid
				if(!_allParentInvalid){
					for(var i:* in _parentInvalid){
						child = (i as IParallaxDisplay);
						_parentItem(child);
					}
				}else{
					_allParentInvalid = false;
				}
				_parentInvalid = new Dictionary();
				
				
				// position invalid
				if(!_allPosInvalid){
					for(i in _posInvalid){
						child = (i as IParallaxDisplay);
						_renderItem(child, _modifiers);
					}
				}else{
					_allPosInvalid = false;
				}
				_posInvalid = new Dictionary();
				
				// depth invalid
				if(_allDepthInvalid){
					organiseDepths(directChildren, _container, this._depthSorter);
					_allDepthInvalid = false;
				}
				
			}
		}
		public function renderItem(item:IParallaxDisplay):void{
			_renderItem(item, _modifiers);
		}
		protected function assessContainer():void{
			if(_doMask){
				_container.scrollRect = scrollRect;
				_container.y = _container.x = 0;
			}else{
				_container.scrollRect = null;
				//_container.x = scrollRect.width/2;
				//_container.y = scrollRect.height/2;
			}
		}
		
		// child handlers
		protected function onChildPosChange(e:Event):void{
			_posInvalid[e.target] = true;
			if(autoRender)render();
		}
		protected function onChildDepthChange(e:Event):void{
			_allDepthInvalid = true;
			if(autoRender)render();
		}
		
		// modifier handlers
		protected function invalidatePosition(e:Event):void{
			_allPosInvalid = true;
			if(autoRender)render();
		}
		protected function invalidateDepth(e:Event):void{
			_allDepthInvalid = true;
			if(autoRender)render();
		}
	}
}