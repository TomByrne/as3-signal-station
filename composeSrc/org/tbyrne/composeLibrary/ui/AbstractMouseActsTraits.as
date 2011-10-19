package org.tbyrne.composeLibrary.ui
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.data.core.BooleanData;
	import org.tbyrne.data.dataTypes.IBooleanProvider;
	import org.tbyrne.compose.concerns.ITraitConcern;
	import org.tbyrne.compose.core.ComposeItem;
	import org.tbyrne.compose.traits.AbstractTrait;
	import org.tbyrne.composeLibrary.types.ui.IMouseActsTrait;
	
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
		
		public function get mouseIsOver():IBooleanProvider{
			return _mouseIsOver;
		}
		
		public function get mouseIsDown():IBooleanProvider{
			return _mouseIsDown;
		}
		
		protected var _mouseIsOver:BooleanData;
		protected var _mouseIsDown:BooleanData;
		
		
		public function AbstractMouseActsTraits()
		{
			_mouseIsOver = new BooleanData();
			_mouseIsDown = new BooleanData();
		}
	}
}