package org.farmcode.actLibrary.display.transition.acts
{
	import flash.display.DisplayObject;
	
	import org.farmcode.actLibrary.display.transition.actTypes.IAdvancedTransitionAct;
	import org.farmcode.acting.acts.UniversalAct;

	public class TransitionAct extends UniversalAct implements IAdvancedTransitionAct
	{
		public function get startDisplay():DisplayObject{
			return _startDisplay;
		}
		public function set startDisplay(value:DisplayObject):void{
			_startDisplay = value;
		}
		public function get endDisplay():DisplayObject{
			return _endDisplay;
		}
		public function set endDisplay(value:DisplayObject):void{
			_endDisplay = value;
		}
		public function get transitions():Array{
			return _transitions;
		}
		public function set transitions(value:Array):void{
			_transitions = value;
		}
		public function get easing():Function{
			return null;
		}
		public function set doTransition(doTransition: Boolean): void{
			this._doTransition = doTransition;
		}
		public function get doTransition():Boolean{
			return this._doTransition;
		}
		
		private var _startDisplay:DisplayObject;
		private var _endDisplay:DisplayObject;
		private var _transitions:Array;
		private var _doTransition: Boolean = true;
		
		public function TransitionAct(){
		}
		
	}
}