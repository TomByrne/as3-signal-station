package org.farmcode.sodalityLibrary.core
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import org.farmcode.sodality.advice.IAdvice;
	import org.farmcode.sodality.advice.MethodAdvice;
	import org.farmcode.sodality.events.AdviceEvent;
	import org.farmcode.sodalityLibrary.external.swfaddress.advice.SetSWFAddressAdvice;
	import org.farmcode.sodalityLibrary.external.swfaddress.adviceTypes.ISetSWFAddressAdvice;
	import org.farmcode.sodalityLibrary.utils.config.advice.GetConfigParamAdvice;
	import org.farmcode.sodalityWebApp.appState.AppStateAdvisor;
	import org.farmcode.sodalityWebApp.appState.advice.SetAppStatesAdvice;
	import org.farmcode.sodalityWebApp.appState.advice.SetSerialisedStateAdvice;
	import org.farmcode.sodalityWebApp.appState.adviceTypes.ISetSerialisedStateAdvice;

	import com.asual.swfaddress.SWFAddressUtilities;
	
	public class StateApplication extends ConfiguredApplication
	{
		protected static const CURRENT_PAGE_URL_PARAM:String = "currentPageUrl";
		
		protected var _pendingState:String;
		protected var _defaultAppStatePath:String;
		protected var _stateAppConfig:IStateAppConfig;
		
		public function StateApplication(asset:DisplayObject=null)
		{
			super(asset);
		}
		override protected function init():void{
			super.init();
			var appStateAdvisor:AppStateAdvisor = new AppStateAdvisor();
			appStateAdvisor.advisorDisplay = container;
		}
		override protected function setRootObject(object:Object):IAdvice{
			_stateAppConfig = (object as IStateAppConfig);
			var nextAdvice:IAdvice;
			var lastAdvice:IAdvice = super.setRootObject(object);
			
			nextAdvice = new SetAppStatesAdvice(_stateAppConfig.appStates);
			nextAdvice.executeAfter = lastAdvice;
			_dynamicAdvisor.dispatchEvent(nextAdvice as Event);
			lastAdvice = nextAdvice;
			
			nextAdvice = new MethodAdvice(this,"commitState");
			nextAdvice.executeAfter = lastAdvice;
			_dynamicAdvisor.dispatchEvent(nextAdvice as Event);
			lastAdvice = nextAdvice;
			
			_swfAddressAdvisor.rootPathAlias = _stateAppConfig.defaultAppStatePath;
			_defaultAppStatePath = SWFAddressUtilities.strictCheck(_stateAppConfig.defaultAppStatePath,true,true);
			
			commitState(lastAdvice);
			
			// we must set the initial page AFTER setting the rootPathAlias
			var getCurrentPage:GetConfigParamAdvice = new GetConfigParamAdvice(CURRENT_PAGE_URL_PARAM);
			getCurrentPage.addEventListener(AdviceEvent.COMPLETE, onCurrentPageRetrieved);
			getCurrentPage.executeAfter = lastAdvice;
			_dynamicAdvisor.dispatchEvent(getCurrentPage);
			
			return lastAdvice;
		}
		
		
		// AppState <--> SWFAddress translation
		[Trigger(triggerTiming="after")]
		public function afterSWFAddressAdvice(cause:ISetSWFAddressAdvice):void{
			// onlyIfNotSet is tested to see if this was the advice fired by onCurrentPageRetrieved
			if(cause.advisor!=this || cause.onlyIfNotSet){
				_pendingState = SWFAddressUtilities.strictCheck(cause.swfAddress,true,true);
				commitState(cause);
			}
		}
		[Trigger(triggerTiming="after")]
		public function afterSetSerialisedState(cause:ISetSerialisedStateAdvice):void{
			if(cause.advisor!=this){
				var state:String = SWFAddressUtilities.strictCheck(cause.serialisedState,true,true);
				if(state==_defaultAppStatePath){
					state = "/";
				}
				
				var swfAdvice:SetSWFAddressAdvice = new SetSWFAddressAdvice(state);
				swfAdvice.executeBefore = cause;
				_dynamicAdvisor.dispatchEvent(swfAdvice);
			}
		}
		public function commitState(before:IAdvice=null): void{
			if(_stateAppConfig && _pendingState){
				if(_pendingState=="/" && _defaultAppStatePath){
					_pendingState = _defaultAppStatePath;
				}
				
				var advice:SetSerialisedStateAdvice = new SetSerialisedStateAdvice(_pendingState);
				advice.executeBefore = before;
				_dynamicAdvisor.dispatchEvent(advice);
				_pendingState = null;
			}
		}
		protected function onCurrentPageRetrieved(e:Event=null):void{
			var getCurrentPage:GetConfigParamAdvice = (e.target as GetConfigParamAdvice);
			var initialValue:String = getCurrentPage.value;
			if(!initialValue){
				initialValue = _stateAppConfig.defaultAppStatePath;
				if(!initialValue){
					initialValue = "";
				}
			}
			_dynamicAdvisor.dispatchEvent(new SetSWFAddressAdvice(initialValue, true));
		}
	}
}