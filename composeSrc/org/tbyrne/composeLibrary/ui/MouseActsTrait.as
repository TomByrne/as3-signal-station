package org.tbyrne.composeLibrary.ui
{
	import flash.display.InteractiveObject;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.utils.getTimer;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.compose.concerns.ITraitConcern;
	import org.tbyrne.compose.concerns.TraitConcern;
	import org.tbyrne.compose.traits.ITrait;
	import org.tbyrne.composeLibrary.types.display2D.IInteractiveObjectTrait;
	import org.tbyrne.data.core.BooleanData;
	import org.tbyrne.data.dataTypes.IBooleanProvider;
	import org.tbyrne.display.actInfo.IMouseActInfo;
	import org.tbyrne.display.assets.nativeAssets.actInfo.MouseActInfo;
	
	public class MouseActsTrait extends AbstractMouseActsTraits
	{
		
		public static const DEFAULT_DRAG_THRESHOLD:uint = 5;
		public static const DEFAULT_CLICK_SPEED:Number = 0.25;
		
		
		
		
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
		private var _interactiveObject:InteractiveObject;
		
		private var _clickBegan:int;
		private var _isDragging:Boolean;
		private var _dragX:int;
		private var _dragY:int;
		private var _stage:Stage;
		
		
		public function MouseActsTrait(){
			super();
			
			dragTreshold = DEFAULT_DRAG_THRESHOLD;
			clickSpeed = DEFAULT_CLICK_SPEED;
			
			addConcern(new TraitConcern(true,false,IInteractiveObjectTrait));
		}
		
		
		override protected function onConcernedTraitAdded(from:ITraitConcern, trait:ITrait):void{
			CONFIG::debug{
				if(_interactiveObjectTrait){
					Log.error("Two IInteractiveObjectTrait objects were found, unsure which to use");
				}
			}
			_interactiveObjectTrait = trait as IInteractiveObjectTrait;
			_interactiveObjectTrait.interactiveObjectChanged.addHandler(onInteractiveObjectChanged);
			setInteractiveObject(_interactiveObjectTrait.interactiveObject);
		}
		
		private function setInteractiveObject(interactiveObject:InteractiveObject):void
		{
			if(_interactiveObject!=interactiveObject){
				if(_interactiveObject){
					_interactiveObject.removeEventListener(MouseEvent.ROLL_OVER, onMouseOver);
					_interactiveObject.removeEventListener(MouseEvent.ROLL_OUT, onMouseOut);
					_interactiveObject.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
					
					_interactiveObject.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				}
				
				_interactiveObject = interactiveObject;
				
				if(_interactiveObject){
					_interactiveObject.addEventListener(MouseEvent.ROLL_OVER, onMouseOver);
					_interactiveObject.addEventListener(MouseEvent.ROLL_OUT, onMouseOut);
					_interactiveObject.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
					
					_interactiveObject.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				}
			}
		}
		
		
		private function onInteractiveObjectChanged(from:IInteractiveObjectTrait):void{
			setInteractiveObject(from.interactiveObject);
		}
		
		
		override protected function onConcernedTraitRemoved(from:ITraitConcern, trait:ITrait):void{
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
				
				if(_isDragging){
					_isDragging = false;
					if(_mouseDragFinish)_mouseDragFinish.perform(this);
				}
			}
			_mouseIsOver.booleanValue = false;
			
			setInteractiveObject(null);
			
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
			_mouseMoved.perform(this,createActInfo(event));
		}
		
		private function createActInfo(event:MouseEvent):IMouseActInfo{
			var ret:MouseActInfo = new MouseActInfo(null, event.altKey, event.ctrlKey, event.shiftKey);
			return ret;
		}
		
		protected function onMouseDown(event:MouseEvent):void{
			_mouseIsDown.booleanValue = true;
			
			_stage = _interactiveObject.stage;
			_stage.addEventListener(MouseEvent.MOUSE_MOVE, onDownMove);
			_stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			
			_dragX = _stage.mouseX;
			_dragY = _stage.mouseY;
			
			_clickBegan = getTimer();
		}
		
		protected function onDownMove(event:MouseEvent):void{
			var xDist:Number = _stage.mouseX-_dragX;
			var yDist:Number = _stage.mouseY-_dragY;
			if(!_isDragging){
				var dist:Number = Math.sqrt((xDist*xDist)+(yDist*yDist));
				if(dist>_dragTreshold){
					// start dragging
					_isDragging = true;
					if(_mouseDragStart)_mouseDragStart.perform(this);
				}
			}
			if(_isDragging){
				if(_mouseDrag)_mouseDrag.perform(this,xDist,yDist);
				
				_dragX = _stage.mouseX;
				_dragY = _stage.mouseY;
			}
				
		}
		
		protected function onMouseUp(event:MouseEvent):void{
			_mouseIsDown.booleanValue = false;
			
			_stage.removeEventListener(MouseEvent.MOUSE_MOVE, onDownMove);
			_stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			_stage = null;
			
			if(_isDragging){
				_isDragging = false;
				if(_mouseDragFinish)_mouseDragFinish.perform(this);
			}else if(_mouseIsOver.booleanValue){
				var timeDiff:int = getTimer()-_clickBegan;
				if(timeDiff<_clickSpeedMS){
					if(_mouseClick)_mouseClick.perform(this);
				}else{
					if(_mouseLongClick)_mouseLongClick.perform(this);
				}
			}
		}
		
		
	}
}