package org.tbyrne.composeLibrary.away3d
{
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.Scene3D;
	import away3d.events.MouseEvent3D;
	
	import flash.geom.Matrix;
	import flash.utils.getTimer;
	
	import org.tbyrne.actInfo.IMouseActInfo;
	import org.tbyrne.actInfo.MouseActInfo;
	import org.tbyrne.compose.concerns.Concern;
	import org.tbyrne.compose.concerns.IConcern;
	import org.tbyrne.compose.traits.ITrait;
	import org.tbyrne.composeLibrary.away3d.types.IChild3dTrait;
	import org.tbyrne.composeLibrary.display2D.types.IPosition2dTrait;
	import org.tbyrne.composeLibrary.ui.AbstractMouseActsTraits;
	import org.tbyrne.utils.KeyTracker;
	
	public class Away3dMouseActsTrait extends AbstractMouseActsTraits 
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
		private var _away3dObjectTrait:IChild3dTrait;
		private var _pos2dTrait:IPosition2dTrait;
		private var _away3dDisplay:Away3dDisplay;
		private var _object3d:ObjectContainer3D;
		
		private var _clickBegan:int;
		private var _dragX:int;
		private var _dragY:int;
		private var _scene:Scene3D;
		
		
		public function Away3dMouseActsTrait(){
			super();
			
			dragTreshold = DEFAULT_DRAG_THRESHOLD;
			clickSpeed = DEFAULT_CLICK_SPEED;
			
			addConcern(new Concern(true,false,false,IChild3dTrait));
			addConcern(new Concern(true,false,false,IPosition2dTrait));
			addConcern(new Concern(false,false,true,Away3dDisplay));
		}
		
		override protected function onConcernedTraitAdded(from:IConcern, trait:ITrait):void{
			var away3dObjectTrait:IChild3dTrait = trait as IChild3dTrait;
			var pos2dTrait:IPosition2dTrait = trait as IPosition2dTrait;
			var away3dDisplay:Away3dDisplay = trait as Away3dDisplay;
			
			if(away3dObjectTrait){
				_away3dObjectTrait = away3dObjectTrait;
				setObjectContainer3d(_away3dObjectTrait.object3d);
			}
			if(pos2dTrait){
				_pos2dTrait = pos2dTrait;
			}
			if(away3dDisplay){
				_away3dDisplay = away3dDisplay;
			}
		}
		
		
		override protected function onConcernedTraitRemoved(from:IConcern, trait:ITrait):void{
			var away3dObjectTrait:IChild3dTrait = trait as IChild3dTrait;
			var pos2dTrait:IPosition2dTrait = trait as IPosition2dTrait;
			var away3dDisplay:Away3dDisplay = trait as Away3dDisplay;
			
			if(away3dObjectTrait){
				if(_down){
					setIsDown(false);
					
					_scene.removeEventListener(MouseEvent3D.MOUSE_MOVE, onDownMove);
					_scene.removeEventListener(MouseEvent3D.MOUSE_UP, onMouseUp);
					_scene = null;
					
					if(_dragging){
						setDragging(false);
						if(_mouseDragFinish)_mouseDragFinish.perform(this, new MouseActInfo(trait,false,false,false,0,0));
					}
				}
				setIsOver(false);
				
				setObjectContainer3d(null);
				
				_away3dObjectTrait = null;
			}
			if(pos2dTrait){
				_pos2dTrait = null;
			}
			if(away3dDisplay){
				_away3dDisplay = null;
			}
		}
		
		
		private function setObjectContainer3d(object3d:ObjectContainer3D):void
		{
			if(_object3d!=object3d){
				if(_object3d){
					_object3d.removeEventListener(MouseEvent3D.MOUSE_OVER, onMouseOver);
					_object3d.removeEventListener(MouseEvent3D.MOUSE_OUT, onMouseOut);
					_object3d.removeEventListener(MouseEvent3D.MOUSE_MOVE, onMouseMove);
					
					_object3d.removeEventListener(MouseEvent3D.MOUSE_DOWN, onMouseDown);
				}
				
				_object3d = object3d;
				
				if(_object3d){
					_object3d.addEventListener(MouseEvent3D.MOUSE_OVER, onMouseOver);
					_object3d.addEventListener(MouseEvent3D.MOUSE_OUT, onMouseOut);
					_object3d.addEventListener(MouseEvent3D.MOUSE_MOVE, onMouseMove);
					
					_object3d.addEventListener(MouseEvent3D.MOUSE_DOWN, onMouseDown);
				}
			}
		}
		
		protected function onMouseOver(event:MouseEvent3D):void{
			setIsOver(true);
		}
		
		protected function onMouseOut(event:MouseEvent3D):void{
			setIsOver(false);
		}
		
		protected function onMouseMove(event:MouseEvent3D):void{
			globalToLocalPos(event.screenX,event.screenY);
			if(_mouseMoved)_mouseMoved.perform(this,createActInfo(event));
		}
		
		private function globalToLocalPos(screenX:Number, screenY:Number):void
		{
			if(_pos2dTrait){
				var viewMat:Matrix = _away3dDisplay.view3D.transform.concatenatedMatrix;
				var scale:Number = (_object3d.sceneTransform.rawData[0]+_object3d.sceneTransform.rawData[5]+_object3d.sceneTransform.rawData[10])/3;
				//trace(((screenX-viewMat.tx)-_pos2dTrait.x2d)*scale*viewMat.a,((screenY-viewMat.ty)-_pos2dTrait.y2d)*scale*viewMat.d);
				setLocalPos(((screenX-viewMat.tx)-_pos2dTrait.x2d)*scale*viewMat.a,((screenY-viewMat.ty)-_pos2dTrait.y2d)*scale*viewMat.d);
			}
		}
		
		private function createActInfo(event:MouseEvent3D):IMouseActInfo{
			var ret:MouseActInfo = new MouseActInfo(null, event.altKey, event.ctrlKey, event.shiftKey, event.screenX, event.screenY);
			return ret;
		}
		
		protected function onMouseDown(event:MouseEvent3D):void{
			setIsDown(true);
			
			_scene = _object3d.scene;
			_scene.addEventListener(MouseEvent3D.MOUSE_MOVE, onDownMove);
			_scene.addEventListener(MouseEvent3D.MOUSE_UP, onMouseUp);
			
			_dragX = event.screenX;
			_dragY = event.screenY;
			
			_clickBegan = getTimer();
		}
		
		protected function onDownMove(event:MouseEvent3D):void{
			globalToLocalPos(event.screenX,event.screenY);
			var xDist:Number = event.screenX-_dragX;
			var yDist:Number = event.screenY-_dragY;
			if(!_dragging){
				var dist:Number = Math.sqrt((xDist*xDist)+(yDist*yDist));
				if(dist>_dragTreshold){
					// start dragging
					setDragging(true);
					if(_mouseDragStart)_mouseDragStart.perform(this, createActInfo(event));
				}
			}
			if(_dragging){
				if(_mouseDrag)_mouseDrag.perform(this, createActInfo(event),xDist,yDist);
				
				_dragX = event.screenX;
				_dragY = event.screenY;
			}
			
		}
		
		protected function onMouseUp(event:MouseEvent3D):void{
			setIsDown(false);
			
			_scene.removeEventListener(MouseEvent3D.MOUSE_MOVE, onDownMove);
			_scene.removeEventListener(MouseEvent3D.MOUSE_UP, onMouseUp);
			_scene = null;
			
			if(_dragging){
				setDragging(false);
				if(_mouseDragFinish)_mouseDragFinish.perform(this, createActInfo(event));
			}else if(_over){
				var timeDiff:int = getTimer()-_clickBegan;
				if(timeDiff<_clickSpeedMS){
					if(_mouseClick)_mouseClick.perform(this, createActInfo(event));
				}else{
					if(_mouseLongClick)_mouseLongClick.perform(this, createActInfo(event));
				}
			}
		}
		
	}
}