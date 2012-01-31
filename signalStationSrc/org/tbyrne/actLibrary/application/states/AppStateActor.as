package org.tbyrne.actLibrary.application.states
{
	import flash.events.Event;
	
	import org.tbyrne.actLibrary.application.states.actTypes.*;
	import org.tbyrne.actLibrary.application.states.acts.*;
	import org.tbyrne.actLibrary.application.states.reactors.IAppStateReactor;
	import org.tbyrne.actLibrary.application.states.states.IAppState;
	import org.tbyrne.actLibrary.core.UniversalActorHelper;
	import org.tbyrne.acting.ActingNamspace;
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.actTypes.IUniversalAct;
	import org.tbyrne.acting.metadata.MetadataActorRegistry;
	import org.tbyrne.acting.universal.UniversalActExecution;
	import org.tbyrne.acting.universal.phases.LogicPhases;
	
	
	use namespace ActingNamspace;
	
	/**
	 * The AppStateAdvisor manages a list of state objects which are used
	 * to serialise/deserialise the Application's state. In combination
	 * with the SWFAddressAdvisor this can be used to easily achieve
	 * very complex deep-linking.
	 */
	public class AppStateActor extends UniversalActorHelper
	{
		private var _historyPos:int;
		private var _history:Vector.<String>;
		private var _state:String;
		private var _states:Array;
		private var _currentState:IAppState;
		private var _currentStateMatch:AppStateMatch;
		
		private var _setSerialisedStateAct:SetSerialisedStateAct;
		private var _setAppStateAct:SetAppStateAct;
		
		public function AppStateActor(){
			super();
			
			metadataTarget = this;
			
			_history = new Vector.<String>();
			
			_setSerialisedStateAct = new SetSerialisedStateAct();
			addChild(_setSerialisedStateAct);
			
			_setAppStateAct = new SetAppStateAct();
			addChild(_setAppStateAct);
		}
		
		
		public var moveInHistoryPhases:Array = [AppStatePhases.MOVE_IN_STATE_HISTORY];
		[ActRule(ActClassRule)]
		[ActReaction(phases="<moveInHistoryPhases>")]
		public function moveInHistory(execution:UniversalActExecution, cause:IMoveInStateHistoryAct):void{
			var newPos:int = _historyPos+cause.steps;
			if(newPos<0)newPos = 0;
			else if(newPos>=_history.length){
				newPos = _history.length-1;
			}
			if(newPos!=_historyPos){
				_historyPos = newPos;
				_state = _history[_historyPos];
				_setSerialisedStateAct.serialisedState = _state;
				_setSerialisedStateAct.perform(execution);
				commitState(execution);
			}
			execution.continueExecution();
		}
		
		public var setSerialisedStatePhases:Array = [AppStatePhases.SET_SERIALISED_STATE];
		[ActRule(ActClassRule)]
		[ActReaction(phases="<setSerialisedStatePhases>")]
		public function setSerialisedState(execution:UniversalActExecution, cause:ISetSerialisedStateAct):void{
			
			if(cause!=_setSerialisedStateAct){
				if(_state!=cause.serialisedState){
					addHistoryPoint(_state);
					
					_state = cause.serialisedState;
					commitState(execution);
				}
			}
			execution.continueExecution();
		}
		
		private function addHistoryPoint(state:String):void{
			if(_historyPos<_history.length-1){
				_history.splice(_historyPos+1,_history.length-(_historyPos+1));
			}
			_history.push(state);
			_historyPos = _history.length-1;
		}
		
		public var setAppStatesPhases:Array = [AppStatePhases.SET_APP_STATES];
		[ActRule(ActClassRule)]
		[ActReaction(phases="<setAppStatesPhases>")]
		public function setStates(execution:UniversalActExecution, cause:ISetAppStatesAct):void{
			_states = cause.states;
			commitState(execution);
			execution.continueExecution();
		}
		public function commitState(execution:UniversalActExecution=null): void{
			if(_states  && _state){
				for(var i:int=0; i<_states.length; i++){
					var state:IAppState = _states[i];
					var match:AppStateMatch = state.match(_state);
					if(match){
						_setAppStateAct.state = state;
						_setAppStateAct.appStateMatch = match;
						_setAppStateAct.perform(execution);
						break;
					}
				}
			}
		}
		public var setAppStatePhases:Array = [AppStatePhases.SET_APP_STATE,LogicPhases.PROCESS_COMMAND];
		[ActRule(ActClassRule)]
		[ActReaction(phases="<setAppStatePhases>")]
		public function setAppState(execution:UniversalActExecution, cause:ISetAppStateAct): void{
			if(!cause.appStateMatch){
				Log.error( "WebAppAdvisor.afterSetState: no appStateMatch in act: "+cause);
			}
			var newState:IAppState = cause.state?cause.state:findState(cause.stateId);
			if(newState){
				var newReactors:Array = newState.reactors;
				var oldReactors:Array = _currentState?_currentState.reactors:[];
				var reactor:IAppStateReactor;
				for each(reactor in newReactors){
					if(oldReactors.indexOf(reactor)==-1){
						performAct(reactor.enable(cause.appStateMatch, _currentStateMatch),execution);
					}else{
						performAct(reactor.refresh(cause.appStateMatch, _currentStateMatch),execution);
					}
				}
				for each(reactor in oldReactors){
					if(newReactors.indexOf(reactor)==-1){
						performAct(reactor.disable(cause.appStateMatch, _currentStateMatch),execution);
					}
				}
				_currentStateMatch = cause.appStateMatch;
				_currentState = newState;
				if(cause!=_setAppStateAct){
					_state = _currentState.reconstitute(_currentStateMatch);
					addHistoryPoint(_state);
					_setSerialisedStateAct.serialisedState = _state;
					_setSerialisedStateAct.perform(execution);
				}
			}else{
				Log.error( "WebAppAdvisor.afterSetState: no appState found with id: "+cause.stateId);
			}
			execution.continueExecution();
		}
		public function performAct(act:IAct, execution:UniversalActExecution):void{
			if(act){
				var uniAct:IUniversalAct = (act as IUniversalAct);
				if(uniAct){
					if(!uniAct.scope){
						uniAct.scope = asset;
						uniAct.perform(execution);
						uniAct.scope = null;
					}else{
						uniAct.perform(execution);
					}
				}else{
					act.perform();
				}
			}
		}
		public function findState(stateId:String):IAppState{
			for each(var state:IAppState in _states){
				if(state.id==stateId)return state;
			}
			return null;
		}
	}
}