package org.farmcode.sodalityLibrary.display.transition.advice
{
	import flash.display.DisplayObject;
	
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.actLibrary.display.transition.actTypes.IAdvancedTransitionAct;

	public class TransitionAdvice extends Advice implements IAdvancedTransitionAct
	{
		[Property(toString="true",clonable="true")]
		public function get startDisplay():DisplayObject{
			return _startDisplay;
		}
		public function set startDisplay(value:DisplayObject):void{
			//if(value!=_startDisplay){
				_startDisplay = value;
			//}
		}
		[Property(toString="true",clonable="true")]
		public function get endDisplay():DisplayObject{
			return _endDisplay;
		}
		public function set endDisplay(value:DisplayObject):void{
			//if(value!=_endDisplay){
				_endDisplay = value;
			//}
		}
		[Property(toString="true",clonable="true")]
		public function get transitions():Array{
			return _transitions;
		}
		public function set transitions(value:Array):void{
			//if(value!=_transitions){
				_transitions = value;
			//}
		}
		public function get easing():Function{
			return null;
		}
		[Property(toString="true",clonable="true")]
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
		
		public function TransitionAdvice(){
		}
		
	}
}