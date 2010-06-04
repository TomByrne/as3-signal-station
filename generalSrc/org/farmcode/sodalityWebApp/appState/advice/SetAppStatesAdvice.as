package org.farmcode.sodalityWebApp.appState.advice
{
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodalityWebApp.appState.adviceTypes.ISetAppStatesAdvice;
	
	public class SetAppStatesAdvice extends Advice implements ISetAppStatesAdvice
	{
		
		[Property(toString="true",clonable="true")]
		public function get states():Array{
			return _states;
		}
		public function set states(value:Array):void{
			_states = value;
		}
		
		private var _states:Array;
		
		public function SetAppStatesAdvice(states:Array=null){
			this.states = states;
		}
	}
}