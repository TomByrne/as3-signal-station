package org.tbyrne.composeLibrary.ui
{
	import flash.display.InteractiveObject;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.utils.getTimer;
	
	import org.tbyrne.actInfo.MouseActInfo;
	import org.tbyrne.compose.concerns.IConcern;
	import org.tbyrne.compose.concerns.Concern;
	import org.tbyrne.compose.traits.ITrait;
	import org.tbyrne.composeLibrary.display2D.types.IInteractiveObjectTrait;
	
	public class MouseActsTrait extends AbstractMouseActsTraits
	{
		
		public static const DEFAULT_DRAG_THRESHOLD:uint = 5;
		public static const DEFAULT_CLICK_SPEED:Number = 0.25;
		
		
		
		public function get interactiveObject():InteractiveObject{
			return _interactiveObject;
		}
		public function set interactiveObject(value:InteractiveObject):void{
			if(_interactiveObject!=value){
				_interactiveObject = value;
				assessInteractiveObject();
			}
		}
		
		
		public function get dragTreshold():uint{
			return _dragTreshold;
		}
		public function set dragTreshold(value:uint):void{
			//if(_dragTreshold!=value){
				_dragTreshold = value;
			//}
		}
		
		public function get clickSpeed():Number{
			return _clickSpeed;
		}
		public function set clickSpeed(value:Number):void{
			//if(_clickSpeed!=value){
				_clickSpeed = value;
				_clickSpeedMS = value*1000
			//}
		}
		
		private var _clickSpeed:Number;
		private var _clickSpeedMS:int;
		private var _dragTreshold:uint;
		private var _interactiveObjectTrait:IInteractiveObjectTrait;
		private var _usedInteractiveObject:InteractiveObject;
		private var _interactiveObject:InteractiveObject;
		
		private var _clickBegan:int;
		private var _dragX:int;
		private var _dragY:int;
		private var _stage:Stage;
		
		
		public function MouseActsTrait(interactiveObject:InteractiveObject=null){
			super();
			this.interactiveObject = interactiveObject;
			
			dragTreshold = DEFAULT_DRAG_THRESHOLD;
			clickSpeed = DEFAULT_CLICK_SPEED;
			
			addConcern(new Concern(true,false,false,IInteractiveObjectTrait));
		}
		
		
		override protected function onConcernedTraitAdded(from:IConcern, trait:ITrait):void{
			CONFIG::debug{
				if(_interactiveObjectTrait && !_interactiveObject){
					Log.error("Two IInteractiveObjectTrait objects were found, unsure which to use");
				}
			}
			_interactiveObjectTrait = trait as IInteractiveObjectTrait;
			_interactiveObjectTrait.interactiveObjectChanged.addHandler(onInteractiveObjectChanged);
			assessInteractiveObject();
		}
		
		private function assessInteractiveObject():void{
			setInteractiveObject(_interactiveObject || _interactiveObjectTrait.interactiveObject);
		}
		private function onInteractiveObjectChanged(from:IInteractiveObjectTrait):void{
			if(!_interactiveObject)setInteractiveObject(from.interactiveObject);
		}
		
		private function setInteractiveObject(interactiveObject:InteractiveObject):void
		{
			if(_usedInteractiveObject!=interactiveObject){
				if(_usedInteractiveObject){
					_usedInteractiveObject.removeEventListener(MouseEvent.ROLL_OVER, onMouseOver);
					_usedInteractiveObject.removeEventListener(MouseEvent.ROLL_OUT, onMouseOut);
					_usedInteractiveObject.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
					
					_usedInteractiveObject.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				}
				
				_usedInteractiveObject = interactiveObject;
				
				if(_usedInteractiveObject){
					_usedInteractiveObject.addEventListener(MouseEvent.ROLL_OVER, onMouseOver);
					_usedInteractiveObject.addEventListener(MouseEvent.ROLL_OUT, onMouseOut);
					_usedInteractiveObject.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
					
					_usedInteractiveObject.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				}
			}
		}
		
		
		
		
		override protected function onConcernedTraitRemoved(from:IConcern, trait:ITrait):void{
			CONFIG::debug{
				if(trait != _interactiveObjectTrait){
					Log.error("Two IInteractiveObjectTrait objects were found, unsure which to use");
				}
			}
			if(_mouseIsDown.booleanValue){
				
				_mouseIsDown.booleanValue = false;
				
				
				_stage.removeEventListener(MouseEvent.MOUSE_MOVE, onDownMove);
				_stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				_stage = null;
				
				if(_mouseIsDragging.booleanValue){
					_mouseIsDragging.booleanValue = false;
					if(_mouseDragFinish)_mouseDragFinish.perform(this);
				}
			}
			_mouseIsOver.booleanValue = false;
			
			if(!_interactiveObject)setInteractiveObject(null);
			
			_interactiveObjectTrait.interactiveObjectChanged.removeHandler(onInteractiveObjectChanged);
			_interactiveObjectTrait = null;
		}
		
		protected function onMouseOver(event:MouseEvent):void{
			_mouseIsOver.booleanValue = true;
		}
		
		protected function onMouseOut(event:MouseEvent):void{
			_mouseIsOver.booleanValue = false;
		}
		
		protected function onMouseMove(event:MouseEvent):void{
			if(_mouseMoved)_mouseMoved.perform(this,createActInfo(event));
		}
		
		private function createActInfo(event:MouseEvent):MouseActInfo{
			var ret:MouseActInfo = new MouseActInfo(null, event.altKey, event.ctrlKey, event.shiftKey, event.stageX, event.stageY);
			return ret;
		}
		
		protected function onMouseDown(event:MouseEvent):void{
			_mouseIsDown.booleanValue = true;
			
			_stage = _usedInteractiveObject.stage;
			_stage.addEventListener(MouseEvent.MOUSE_MOVE, onDownMove);
			_stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			
			_dragX = _stage.mouseX;
			_dragY = _stage.mouseY;
			
			_clickBegan = getTimer();
		}
		
		protected function onDownMove(event:MouseEvent):void{
			var xDist:Number = _stage.mouseX-_dragX;
			var yDist:Number = _stage.mouseY-_dragY;
			if(!_mouseIsDragging.booleanValue){
				var dist:Number = Math.sqrt((xDist*xDist)+(yDist*yDist));
				if(dist>_dragTreshold){
					// start dragging
					_mouseIsDragging.booleanValue = true;
					var mouseActInfo:MouseActInfo = createActInfo(event);
					mouseActInfo.screenX = _dragX;
					mouseActInfo.screenY = _dragY;
					if(_mouseDragStart)_mouseDragStart.perform(this,mouseActInfo);
				}
			}
			if(_mouseIsDragging.booleanValue){
				if(_mouseDrag)_mouseDrag.perform(this,createActInfo(event),xDist,yDist);
				
				_dragX = _stage.mouseX;
				_dragY = _stage.mouseY;
			}
				
		}
		
		protected function onMouseUp(event:MouseEvent):void{
			_mouseIsDown.booleanValue = false;
			
			_stage.removeEventListener(MouseEvent.MOUSE_MOVE, onDownMove);
			_stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			_stage = null;
			
			if(_mouseIsDragging.booleanValue){
				_mouseIsDragging.booleanValue = false;
				if(_mouseDragFinish)_mouseDragFinish.perform(this,createActInfo(event));
			}else if(_mouseIsOver.booleanValue){
				var timeDiff:int = getTimer()-_clickBegan;
				if(timeDiff<_clickSpeedMS){
					if(_mouseClick)_mouseClick.perform(this,createActInfo(event));
				}else{
					if(_mouseLongClick)_mouseLongClick.perform(this,createActInfo(event));
				}
			}
		}
		
		
	}
}