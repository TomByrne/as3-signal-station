package org.farmcode.sodalityWebApp.appState
{
	import flash.events.Event;
	
	import org.farmcode.sodality.advice.IAdvice;
	import org.farmcode.sodality.advisors.DynamicAdvisor;
	import org.farmcode.sodalityWebApp.appState.advice.*;
	import org.farmcode.sodalityWebApp.appState.adviceTypes.*;
	import org.farmcode.sodalityWebApp.appState.reactors.IAppStateReactor;
	import org.farmcode.sodalityWebApp.appState.states.IAppState;
	
	/**
	 * The AppStateAdvisor manages a list of state objects which are used
	 * to serialise/deserialise the Application's state. In combination
	 * with the SWFAddressAdvisor this can be used to easily achieve
	 * very complex deep-linking.
	 */
	public class AppStateAdvisor extends DynamicAdvisor
	{
		private var _state:String;
		private var _states:Array;
		private var _currentState:IAppState;
		private var _currentStateMatch:AppStateMatch;
		
		public function AppStateAdvisor(){
			super();
		}
		[Trigger(triggerTiming="after")]
		public function afterSetSerialisedState(cause:ISetSerialisedStateAdvice):void{
			if(cause.advisor!=this){
				if(_state!=cause.serialisedState){
					_state = cause.serialisedState;
					commitState(cause);
				}
			}
		}
		[Trigger(triggerTiming="after")]
		public function afterSetStates(cause:ISetAppStatesAdvice):void{
			if(cause.advisor!=this){
				_states = cause.states;
				commitState(cause);
			}
		}
		public function commitState(before:IAdvice=null): void{
			if(_states  && _state){
				for(var i:int=0; i<_states.length; i++){
					var state:IAppState = _states[i];
					var match:AppStateMatch = state.match(_state);
					if(match){
						var advice:SetAppStateAdvice = new SetAppStateAdvice();
						advice.state = state;
						advice.appStateMatch = match;
						advice.executeBefore = before;
						dispatchEvent(advice);
						break;
					}
				}
			}
		}
		[Trigger(type="org.farmcode.sodalityLibrary.triggers.ImmediateAfterTrigger")]
		public function afterSetState(cause:ISetAppStateAdvice): void{
			if(!cause.appStateMatch){
				throw new Error("WebAppAdvisor.afterSetState: no appStateMatch in advice: "+cause);
			}
			var newState:IAppState = cause.state?cause.state:findState(cause.stateId);
			if(newState){
				var newReactors:Array = newState.reactors;
				var oldReactors:Array = _currentState?_currentState.reactors:[];
				var reactor:IAppStateReactor;
				for each(reactor in newReactors){
					var advice:IAdvice;
					if(oldReactors.indexOf(reactor)==-1){
						advice = reactor.enable(cause.appStateMatch, _currentStateMatch);
					}else{
						advice = reactor.refresh(cause.appStateMatch, _currentStateMatch);
					}
					if(advice){
						advice.executeBefore = cause;
						dispatchEvent(advice as Event);
					}
				}
				for each(reactor in oldReactors){
					if(newReactors.indexOf(reactor)==-1){
						reactor.disable(cause.appStateMatch, _currentStateMatch);
					}
				}
				_currentStateMatch = cause.appStateMatch;
				_currentState = newState;
				if(cause.advisor!=this){
					_state = _currentState.reconstitute(_currentStateMatch);
					var stateAdvice:SetSerialisedStateAdvice = new SetSerialisedStateAdvice(_state);
					stateAdvice.executeBefore = cause;
					dispatchEvent(stateAdvice);
				}
			}else{
				throw new Error("WebAppAdvisor.afterSetState: no appState found with id: "+cause.stateId);
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