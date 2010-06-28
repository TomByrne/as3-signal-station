package org.farmcode.actLibrary.display.transition.acts
{
	import org.farmcode.actLibrary.display.transition.actTypes.IAdvancedTransitionAct;
	import org.farmcode.acting.acts.UniversalAct;
	import org.farmcode.display.assets.IDisplayAsset;

	public class TransitionAct extends UniversalAct implements IAdvancedTransitionAct
	{
		public function get startDisplay():IDisplayAsset{
			return _startDisplay;
		}
		public function set startDisplay(value:IDisplayAsset):void{
			_startDisplay = value;
		}
		public function get endDisplay():IDisplayAsset{
			return _endDisplay;
		}
		public function set endDisplay(value:IDisplayAsset):void{
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
		
		private var _startDisplay:IDisplayAsset;
		private var _endDisplay:IDisplayAsset;
		private var _transitions:Array;
		private var _doTransition: Boolean = true;
		
		public function TransitionAct(){
		}
		
	}
}