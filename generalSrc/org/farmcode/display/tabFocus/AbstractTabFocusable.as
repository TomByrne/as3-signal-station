package org.farmcode.display.tabFocus
{
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;

	public class AbstractTabFocusable implements ITabFocusable
	{
		
		/**
		 * @inheritDoc
		 */
		public function get focusIn():IAct{
			if(!_focusIn)_focusIn = new Act();
			return _focusIn;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get focusOut():IAct{
			if(!_focusOut)_focusOut = new Act();
			return _focusOut;
		}
		
		protected var _focusOut:Act;
		protected var _focusIn:Act;
		
		
		
		public function AbstractTabFocusable()
		{
		}
		
		public function get focused():Boolean{
			return false;
		}
		public function set focused(value:Boolean):void{
		}
		
		public function get tabIndicesRequired():uint{
			return 0;
		}
		
		public function set tabIndex(value:int):void{
		}
		public function set tabEnabled(value:Boolean):void{
		}
		
		
	}
}