package org.farmcode.actLibrary.application.states.acts
{
	import org.farmcode.actLibrary.application.states.actTypes.ISetSerialisedStateAct;
	import org.farmcode.acting.acts.UniversalAct;
	import org.farmcode.sodality.advice.Advice;
	
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