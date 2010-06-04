package au.com.thefarmdigital.display.scrolling
{
	import au.com.thefarmdigital.structs.ScrollMetrics;
	import au.com.thefarmdigital.utils.DisplayUtils;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import org.farmcode.display.constants.Direction;
	import org.tbyrne.motion.AtomicMotion;
	import org.tbyrne.motion.AtomicMotionEvent;
	
	/**
	 * The ProximityScroller scrolls the subject based on the proximity of the mouse to the edge
	 * of the subjects bounds.
	 */
	public class ProximityScroller{
		
		public function get subject():IScrollable{
			return _subject;
		}
		public function set subject(value:IScrollable):void{
			if(_subject != value){
				if(_subject){
					_subject.scrollMetricsChanged.removeHandler(onScroll);
				}
				_subject = value;
				if(_subject){
					_subject.scrollMetricsChanged.addHandler(onScroll);
					if(!scrollDisplay){
						scrollDisplay = (_subject as InteractiveObject);
					}
					assessMotions();
				}
			}
		}
		
		public function get scrollDisplay():InteractiveObject{
			return _scrollDisplay;
		}
		public function set scrollDisplay(value:InteractiveObject):void{
			if(_scrollDisplay != value){
				if(_scrollDisplay){
					_scrollDisplay.removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
					_scrollDisplay.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
				}
				_scrollDisplay = value;
				if(_scrollDisplay){
					_scrollDisplay.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
					_scrollDisplay.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
				}
			}
		}
		
		public function get vertical():Boolean{
			return _vertical;
		}
		public function set vertical(value:Boolean):void{
			if(_vertical != value){
				_vertical = value;
				assessMotions();
			}
		}
		
		public function get horizontal():Boolean{
			return _horizontal;
		}
		public function set horizontal(value:Boolean):void{
			if(_horizontal != value){
				_horizontal = value;
				assessMotions();
			}
		}
		
		public function get mass():Number{
			return _mass;
		}
		public function set mass(value:Number):void{
			if(_mass != value){
				_mass = value;
				if(xMotion)xMotion.mass = value;
				if(yMotion)yMotion.mass = value;
			}
		}
		
		public function get acceleration():Number{
			return _acceleration;
		}
		public function set acceleration(value:Number):void{
			if(_acceleration != value){
				_acceleration = value;
				if(xMotion)xMotion.acceleration = value;
				if(yMotion)yMotion.acceleration = value;
			}
		}
		
		public function get decceleration():Number{
			return _decceleration;
		}
		public function set decceleration(value:Number):void{
			if(_decceleration != value){
				_decceleration = value;
				if(xMotion)xMotion.decceleration = value;
				if(yMotion)yMotion.decceleration = value;
			}
		}
		
		public var zoneSize:Number = 10;
		public var speed:Number = 1;
		
		private var _mass:Number = 1;
		private var _acceleration:Number = 1;
		private var _decceleration:Number = 1;
		private var _vertical:Boolean = true;
		private var _horizontal:Boolean = true;
		private var _listening:Boolean = false;
		private var _ignoreChanges:Boolean = false;
		private var _scrollDisplay:InteractiveObject;
		private var _subject:IScrollable;
		
		private var xMotion:AtomicMotion;
		private var yMotion:AtomicMotion;
		
		private var _xScrollMetrics:ScrollMetrics;
		private var _yScrollMetrics:ScrollMetrics;
		
		protected function onScroll(from:IScrollable, direction:String, scrollMetrics:ScrollMetrics):void{
			if(_subject && !_ignoreChanges){
				if(direction==Direction.HORIZONTAL){
					_xScrollMetrics = scrollMetrics;
					xMotion.value = scrollMetrics.value;
				}else if(_vertical){
					_yScrollMetrics = scrollMetrics;
					yMotion.value = scrollMetrics.value;
				}
			}
		}
		protected function onXChange(e:Event):void{
			_ignoreChanges = true;
			_xScrollMetrics.value = xMotion.value;
			_subject.setScrollMetrics(Direction.HORIZONTAL,_xScrollMetrics);
			_ignoreChanges = false;
		}
		protected function onYChange(e:Event):void{
			_ignoreChanges = true;
			_yScrollMetrics.value = yMotion.value;
			_subject.setScrollMetrics(Direction.VERTICAL,_yScrollMetrics);
			_ignoreChanges = false;
		}
		protected function assessMotions():void{
			if(_subject && _horizontal){
				if(!xMotion){
					xMotion = new AtomicMotion(_mass,_acceleration,_decceleration);
					xMotion.rounding = 0.01;
					xMotion.addEventListener(AtomicMotionEvent.VALUE_CHANGE, onXChange);
				}
				if(!_xScrollMetrics){
					_xScrollMetrics = _subject.getScrollMetrics(Direction.HORIZONTAL);
					xMotion.value = _xScrollMetrics.value;
				}
			}else if(xMotion){
				xMotion.removeEventListener(AtomicMotionEvent.VALUE_CHANGE, onXChange);
				xMotion = null;
			}
			if(_subject && _vertical){
				if(!yMotion){
					yMotion = new AtomicMotion(_mass,_acceleration,_decceleration);
					yMotion.rounding = 0.01;
					yMotion.addEventListener(AtomicMotionEvent.VALUE_CHANGE, onYChange);
				}
				if(!_yScrollMetrics){
					_yScrollMetrics = _subject.getScrollMetrics(Direction.VERTICAL);
					yMotion.value = _yScrollMetrics.value;
				}
			}else if(yMotion){
				yMotion.removeEventListener(AtomicMotionEvent.VALUE_CHANGE, onYChange);
				yMotion = null;
			}
			if(_subject){
				assessVelocity();
			}
		}
		protected function assessVelocity():void{
			var bounds:Rectangle = _scrollDisplay.getBounds(_scrollDisplay);
			
			if(_horizontal){
				var mx:Number = _scrollDisplay.mouseX;
				var velocityX:Number = 0;
				if(mx>bounds.left && mx<bounds.left+zoneSize){
					velocityX = -1;
				}else if(mx<bounds.right && mx>bounds.right-zoneSize){
					velocityX = 1;
				}
				if(velocityX){
					xMotion.start();
					xMotion.destination = Math.min(Math.max(xMotion.value+(velocityX*speed),_xScrollMetrics.minimum),_xScrollMetrics.maximum);
				}
			}
			
			if(_vertical){
				var my:Number = _scrollDisplay.mouseY;
				var velocityY:Number = 0;
				if(my>bounds.top && my<bounds.top+zoneSize){
					velocityY = -1;
				}else if(my<bounds.bottom && my>bounds.bottom-zoneSize){
					velocityY = 1;
				}
				if(velocityY){
					yMotion.start();
					yMotion.destination = Math.min(Math.max(yMotion.value+(velocityY*speed),_yScrollMetrics.minimum),_yScrollMetrics.maximum-_yScrollMetrics.pageSize);
				}
			}
		}
		protected function onMouseOver(e:MouseEvent):void{
			if(!_listening){
				_listening = true;
				_scrollDisplay.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			}
		}
		protected function onMouseOut(e:MouseEvent):void{
			var cast:DisplayObjectContainer = (_scrollDisplay as DisplayObjectContainer);
			var desc:Boolean = (cast && e.relatedObject && DisplayUtils.isDescendant(cast,e.relatedObject))
			if(_listening && !desc){
				_listening = false;
				_scrollDisplay.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			}
		}
		protected function onEnterFrame(e:Event):void{
			assessVelocity();
		}
	}
}