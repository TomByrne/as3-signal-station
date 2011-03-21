package org.tbyrne.actLibrary.application
{
	import com.asual.swfaddress.SWFAddressUtilities;
	
	import flash.display.DisplayObject;
	
	import org.tbyrne.actLibrary.application.states.AppStateActor;
	import org.tbyrne.actLibrary.application.states.AppStatePhases;
	import org.tbyrne.actLibrary.application.states.actTypes.ISetSerialisedStateAct;
	import org.tbyrne.actLibrary.application.states.acts.SetAppStatesAct;
	import org.tbyrne.actLibrary.application.states.acts.SetSerialisedStateAct;
	import org.tbyrne.actLibrary.core.SingleMethodReaction;
	import org.tbyrne.actLibrary.external.config.ConfigPhases;
	import org.tbyrne.actLibrary.external.config.acts.GetConfigParamAct;
	import org.tbyrne.actLibrary.external.swfAddress.SWFAddressPhases;
	import org.tbyrne.actLibrary.external.swfAddress.actTypes.ISetSWFAddressAct;
	import org.tbyrne.actLibrary.external.swfAddress.acts.SetSWFAddressAct;
	import org.tbyrne.acting.actTypes.IUniversalAct;
	import org.tbyrne.acting.universal.UniversalActExecution;
	import org.tbyrne.acting.universal.rules.ActInstanceRule;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
	
	public class StateApplication extends ConfiguredApplication
	{
		protected static const CURRENT_PAGE_URL_PARAM:String = "currentPageUrl";
		
		protected var _pendingState:String;
		protected var _defaultAppStatePath:String;
		protected var _stateAppConfig:IStateAppConfig;
		
		
		private var _setSWFAddressAct:SetSWFAddressAct;
		private var _setSerialisedStateAct:SetSerialisedStateAct;
		
		public function StateApplication()
		{
			
			_setSWFAddressAct = new SetSWFAddressAct();
			
			_setSerialisedStateAct = new SetSerialisedStateAct();
		}
		override protected function init():void{
			super.init();
			_universalActorHelper.addChild(_setSerialisedStateAct);
			_universalActorHelper.addChild(_setSWFAddressAct);
			var appStateActor:AppStateActor = new AppStateActor();
			addActor(appStateActor);
		}
		override protected function setRootObject(execution:UniversalActExecution, object:Object):void{
			_stateAppConfig = (object as IStateAppConfig);
			
			super.setRootObject(execution, object);
			
			if(_stateAppConfig.appStates && _stateAppConfig.appStates.length){
				setStates(_stateAppConfig.appStates);
			}
			
			
			_swfAddressActor.rootPathAlias = _stateAppConfig.defaultAppStatePath;
			_defaultAppStatePath = SWFAddressUtilities.strictCheck(_stateAppConfig.defaultAppStatePath,true,true);
			
			commitState(execution);
			
			// we must set the initial page AFTER setting the rootPathAlias
			var getCurrentPage:GetConfigParamAct = new GetConfigParamAct(CURRENT_PAGE_URL_PARAM);
			var reaction:SingleMethodReaction = new SingleMethodReaction(null,onCurrentPageRetrieved,new ActInstanceRule(getCurrentPage,null,[ConfigPhases.GET_PARAM]),true);
			reaction.passAct = true;
			temporaryPerformAct(getCurrentPage,execution);
		}
		protected function setStates(states:Array, execution:UniversalActExecution=null):void{
			var setStates:IUniversalAct = new SetAppStatesAct(states);
			new SingleMethodReaction(null,commitState,new ActInstanceRule(setStates,null,[AppStatePhases.SET_APP_STATES]),false);
			temporaryPerformAct(setStates,execution);
		}
		
		
		
		
		// AppState <--> SWFAddress translation
		
		public var swfAddressChangedPhases:Array = [AppStatePhases.SET_APP_STATE];
		public var swfAddressChangedAfterPhases:Array = [SWFAddressPhases.SET_SWF_ADDRESS];
		[ActRule(ActClassRule,afterPhases="<swfAddressChangedAfterPhases>")]
		[ActReaction(phases="<swfAddressChangedPhases>")]
		public function swfAddressChanged(execution:UniversalActExecution, cause:ISetSWFAddressAct):void{
			// onlyIfNotSet is tested to see if this was the act fired by onCurrentPageRetrieved
			if(cause!=_setSWFAddressAct || cause.onlyIfNotSet){
				_pendingState = SWFAddressUtilities.strictCheck(cause.swfAddress,true,true);
				commitState(execution);
			}
			execution.continueExecution();
		}
		
		
		public var serialisedStateChangedPhases:Array = [SWFAddressPhases.SET_SWF_ADDRESS];
		public var serialisedStateChangedAfterPhases:Array = [AppStatePhases.SET_SERIALISED_STATE];
		[ActRule(ActClassRule,afterPhases="<serialisedStateChangedAfterPhases>")]
		[ActReaction(phases="<serialisedStateChangedPhases>")]
		public function serialisedStateChanged(execution:UniversalActExecution, cause:ISetSerialisedStateAct):void{
			
			if(cause!=_setSerialisedStateAct){
				var state:String = SWFAddressUtilities.strictCheck(cause.serialisedState,true,true);
				if(state==_defaultAppStatePath){
					state = "/";
				}
				
				_setSWFAddressAct.swfAddress = state;
				_setSWFAddressAct.onlyIfNotSet = false;
				_setSWFAddressAct.perform(execution);
			}
			execution.continueExecution();
		}
		public function commitState(execution:UniversalActExecution=null): void{
			if(_stateAppConfig && _pendingState){
				if(_pendingState=="/" && _defaultAppStatePath){
					_pendingState = _defaultAppStatePath;
				}
				
				_setSerialisedStateAct.serialisedState = _pendingState;
				_setSerialisedStateAct.perform(execution);
				_pendingState = null;
			}
		}
		protected function onCurrentPageRetrieved(execution:UniversalActExecution, getCurrentPage:GetConfigParamAct):void{
			var initialValue:String = getCurrentPage.value;
			if(!initialValue){
				initialValue = _stateAppConfig.defaultAppStatePath;
				if(!initialValue){
					initialValue = "";
				}
			}
			
			_setSWFAddressAct.swfAddress = initialValue;
			_setSWFAddressAct.onlyIfNotSet = true;
			_setSWFAddressAct.perform(execution);
		}
	}
}