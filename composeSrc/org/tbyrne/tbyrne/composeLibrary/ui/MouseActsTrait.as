package org.tbyrne.tbyrne.composeLibrary.ui
{
	import flash.display.InteractiveObject;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.utils.getTimer;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.tbyrne.compose.concerns.TraitConcern;
	import org.tbyrne.tbyrne.compose.traits.AbstractTrait;
	import org.tbyrne.tbyrne.compose.traits.ITrait;
	import org.tbyrne.tbyrne.compose.concerns.ITraitConcern;
	import org.tbyrne.tbyrne.composeLibrary.types.display2D.IInteractiveObjectTrait;
	import org.tbyrne.tbyrne.composeLibrary.types.ui.IMouseActsTrait;
	import org.tbyrne.data.core.BooleanData;
	import org.tbyrne.data.dataTypes.IBooleanProvider;
	
	public class MouseActsTrait extends AbstractTrait implements IMouseActsTrait
	{
		
		public static const DEFAULT_DRAG_THRESHOLD:uint = 5;
		public static const DEFAULT_CLICK_SPEED:Number = 0.25;
		
		/**
		 * @inheritDoc
		 */
		public function get mouseClick():IAct{
			return (_mouseClick || (_mouseClick = new Act()));
		}
		
		/**
		 * @inheritDoc
		 */
		public function get mouseDrag():IAct{
			return (_mouseDrag || (_mouseDrag = new Act()));
		}
		
		/**
		 * @inheritDoc
		 */
		public function get mouseLongClick():IAct{
			return (_mouseLongClick || (_mouseLongClick = new Act()));
		}
		
		/**
		 * @inheritDoc
		 */
		public function get mouseDragStart():IAct{
			return (_mouseDragStart || (_mouseDragStart = new Act()));
		}
		
		/**
		 * @inheritDoc
		 */
		public function get mouseDragFinish():IAct{
			return (_mouseDragFinish || (_mouseDragFinish = new Act()));
		}
		
		protected var _mouseDragFinish:Act;
		protected var _mouseDragStart:Act;
		protected var _mouseLongClick:Act;
		protected var _mouseDrag:Act;
		protected var _mouseClick:Act;
		
		
		
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
		
		public function get mouseIsOver():IBooleanProvider{
			return _mouseIsOver;
		}
		
		public function get mouseIsDown():IBooleanProvider{
			return _mouseIsDown;
		}
		
		private var _mouseIsOver:BooleanData;
		private var _mouseIsDown:BooleanData;
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
			
			_mouseIsOver = new BooleanData();
			_mouseIsDown = new BooleanData();
			
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
					
					_interactiveObject.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				}
				
				_interactiveObject = interactiveObject;
				
				if(_interactiveObject){
					_interactiveObject.addEventListener(MouseEvent.ROLL_OVER, onMouseOver);
					_interactiveObject.addEventListener(MouseEvent.ROLL_OUT, onMouseOut);
					
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
				
				
				_stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
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
		
		protected function onMouseDown(event:MouseEvent):void{
			_mouseIsDown.booleanValue = true;
			
			_stage = _interactiveObject.stage;
			_stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			_stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			
			_dragX = _stage.mouseX;
			_dragY = _stage.mouseY;
			
			_clickBegan = getTimer();
		}
		
		protected function onMouseMove(event:MouseEvent):void{
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
			
			_stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
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