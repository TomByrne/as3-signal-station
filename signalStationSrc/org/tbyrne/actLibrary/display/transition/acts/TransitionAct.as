package org.tbyrne.actLibrary.display.transition.acts
{
	import org.tbyrne.actLibrary.display.transition.actTypes.IAdvancedTransitionAct;
	import org.tbyrne.acting.acts.UniversalAct;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;

	public class TransitionAct extends UniversalAct implements IAdvancedTransitionAct
	{
		public function get startDisplay():IDisplayObject{
			return _startDisplay;
		}
		public function set startDisplay(value:IDisplayObject):void{
			_startDisplay = value;
		}
		public function get endDisplay():IDisplayObject{
			return _endDisplay;
		}
		public function set endDisplay(value:IDisplayObject):void{
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
		
		private var _startDisplay:IDisplayObject;
		private var _endDisplay:IDisplayObject;
		private var _transitions:Array;
		private var _doTransition: Boolean = true;
		
		public function TransitionAct(){
		}
		
	}
}