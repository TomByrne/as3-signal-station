package org.tbyrne.actLibrary.application.states.acts
{
	import flash.utils.Dictionary;
	
	import org.tbyrne.actLibrary.application.states.AppStateMatch;
	import org.tbyrne.actLibrary.application.states.actTypes.ISetAppStateAct;
	import org.tbyrne.actLibrary.application.states.states.IAppState;
	import org.tbyrne.actLibrary.display.progress.actTypes.IExecutionProgressAct;
	import org.tbyrne.acting.acts.UniversalAct;
	
	public class SetAppStateAct extends UniversalAct implements ISetAppStateAct, IExecutionProgressAct
	{
		
		public function get state():IAppState{
			return _state;
		}
		public function set state(value:IAppState):void{
			if(_stateId && value)_stateId = null;
			_state = value;
		}
		public function get stateId():String{
			return _state?_state.id:_stateId;
		}
		public function set stateId(value:String):void{
			if(_state && value){
				if(value==_state.id)return;
				else _state = null;
			}
			_stateId = value;
		}
		public function set parameters(value:Object):void{
			if(value){
				if(!_appStateMatch)_appStateMatch = new AppStateMatch();
				var parameters:Dictionary = new Dictionary();
				for(var i:* in value){
					parameters[i] = value[i];
				}
				_appStateMatch.parameters = parameters;
			}else if(_appStateMatch){
				_appStateMatch.parameters = null;
			}
		}
		public function set appStateMatch(value:AppStateMatch):void{
			_appStateMatch = value;
		}
		public function get appStateMatch():AppStateMatch{
			if(!_appStateMatch)_appStateMatch = new AppStateMatch();
			return _appStateMatch;
		}
		public function get message():String{
			return "Loading";
		}
		
		private var _state:IAppState;
		private var _stateId:String;
		private var _appStateMatch:AppStateMatch;
		
		public function SetAppStateAct(stateId:String=null, parameters:Object=null){
			super();
			this.stateId = stateId;
			this.parameters = parameters;
		}
		public function addParameter(data:*, parameter:String = "*"):void{
			if(data!=null){
				if(!_appStateMatch)_appStateMatch = new AppStateMatch();
				if(!_appStateMatch.parameters)_appStateMatch.parameters = new Dictionary();
				_appStateMatch.parameters[parameter] = data;
			}else{
				removeParameter(parameter);
			}
		}
		public function removeParameter(parameter:String):void{
			if(_appStateMatch && _appStateMatch.parameters){
				delete _appStateMatch.parameters[parameter];
			}
		}
	}
}