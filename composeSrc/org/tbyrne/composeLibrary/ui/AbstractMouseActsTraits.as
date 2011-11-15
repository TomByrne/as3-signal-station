package org.tbyrne.composeLibrary.ui
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.compose.concerns.IConcern;
	import org.tbyrne.compose.core.ComposeItem;
	import org.tbyrne.compose.traits.AbstractTrait;
	import org.tbyrne.composeLibrary.ui.types.IMouseActsTrait;
	import org.tbyrne.data.core.BooleanData;
	import org.tbyrne.data.core.NumberData;
	import org.tbyrne.data.dataTypes.IBooleanProvider;
	import org.tbyrne.data.dataTypes.INumberProvider;
	
	public class AbstractMouseActsTraits extends AbstractTrait implements IMouseActsTrait
	{
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
		
		/**
		 * @inheritDoc
		 */
		public function get mouseMoved():IAct{
			return (_mouseMoved || (_mouseMoved = new Act()));
		}
		
		protected var _mouseMoved:Act;
		protected var _mouseDragFinish:Act;
		protected var _mouseDragStart:Act;
		protected var _mouseLongClick:Act;
		protected var _mouseDrag:Act;
		protected var _mouseClick:Act;
		
		public function get localMouseX():INumberProvider{
			if(!_localMouseX)_localMouseX = new NumberData(_localX);
			return _localMouseX;
		}
		public function get localMouseY():INumberProvider{
			if(!_localMouseY)_localMouseY = new NumberData(_localY);
			return _localMouseY;
		}
		
		public function get mouseIsOver():IBooleanProvider{
			if(!_mouseIsOver)_mouseIsOver = new BooleanData(_over);
			return _mouseIsOver;
		}
		
		public function get mouseIsDown():IBooleanProvider{
			if(!_mouseIsDown)_mouseIsDown = new BooleanData(_down);
			return _mouseIsDown;
		}
		
		public function get mouseIsDragging():IBooleanProvider{
			if(!_mouseIsDragging)_mouseIsDragging = new BooleanData(_dragging);
			return _mouseIsDragging;
		}
		
		private var _localMouseX:NumberData;
		private var _localMouseY:NumberData;
		private var _mouseIsOver:BooleanData;
		private var _mouseIsDown:BooleanData;
		private var _mouseIsDragging:BooleanData;
		
		protected var _dragging:Boolean;
		protected var _down:Boolean;
		protected var _over:Boolean;
		protected var _localX:Number;
		protected var _localY:Number;
		
		public function AbstractMouseActsTraits()
		{
		}
		
		protected function setDragging(value:Boolean):void{
			if(_dragging!=value){
				_dragging = value;
				if(_mouseIsDragging)_mouseIsDragging.booleanValue = value;
			}
		}
		protected function setIsDown(value:Boolean):void{
			if(_down!=value){
				_down = value;
				if(_mouseIsDown)_mouseIsDown.booleanValue = value;
			}
		}
		protected function setIsOver(value:Boolean):void{
			if(_over!=value){
				_over = value;
				if(_mouseIsOver)_mouseIsOver.booleanValue = value;
			}
		}
		protected function setLocalPos(x:Number, y:Number):void{
			if(_localX!=x || _localY!=y){
				_localX = x;
				_localY = y;
				if(_localMouseX)_localMouseX.numericalValue = x;
				if(_localMouseY)_localMouseY.numericalValue = y;
			}
		}
	}
}