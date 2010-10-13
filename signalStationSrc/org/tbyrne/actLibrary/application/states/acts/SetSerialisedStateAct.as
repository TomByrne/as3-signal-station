package org.tbyrne.actLibrary.application.states.acts
{
	import org.tbyrne.actLibrary.application.states.actTypes.ISetSerialisedStateAct;
	import org.tbyrne.acting.acts.UniversalAct;
	
	public class SetSerialisedStateAct extends UniversalAct implements ISetSerialisedStateAct
	{
		public function get serialisedState():String{
			return _serialisedState;
		}
		public function set serialisedState(value:String):void{
			_serialisedState = value;
		}
		
		private var _serialisedState:String;
		
		public function SetSerialisedStateAct(serialisedState:String=null){
			super();
			this.serialisedState = serialisedState;
		}
	}
}