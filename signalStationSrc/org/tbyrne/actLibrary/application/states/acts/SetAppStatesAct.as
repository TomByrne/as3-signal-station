package org.tbyrne.actLibrary.application.states.acts
{
	import org.tbyrne.actLibrary.application.states.actTypes.ISetAppStatesAct;
	import org.tbyrne.acting.acts.UniversalAct;
	
	public class SetAppStatesAct extends UniversalAct implements ISetAppStatesAct
	{
		public function get states():Array{
			return _states;
		}
		public function set states(value:Array):void{
			_states = value;
		}
		
		private var _states:Array;
		
		public function SetAppStatesAct(states:Array=null){
			this.states = states;
		}
	}
}