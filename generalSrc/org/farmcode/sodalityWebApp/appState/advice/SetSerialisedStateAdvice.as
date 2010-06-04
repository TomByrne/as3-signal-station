package org.farmcode.sodalityWebApp.appState.advice
{
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodalityWebApp.appState.adviceTypes.ISetSerialisedStateAdvice;
	
	public class SetSerialisedStateAdvice extends Advice implements ISetSerialisedStateAdvice
	{
		
		[Property(toString="true",clonable="true")]
		public function get serialisedState():String{
			return _serialisedState;
		}
		public function set serialisedState(value:String):void{
			_serialisedState = value;
		}
		
		private var _serialisedState:String;
		
		public function SetSerialisedStateAdvice(serialisedState:String=null){
			super();
			this.serialisedState = serialisedState;
		}
	}
}