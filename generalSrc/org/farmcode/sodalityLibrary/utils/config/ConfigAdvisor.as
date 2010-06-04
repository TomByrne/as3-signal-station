package org.farmcode.sodalityLibrary.utils.config
{
	import flash.display.DisplayObject;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import org.farmcode.sodality.advice.AsyncMethodAdvice;
	import org.farmcode.sodality.advisors.DynamicAdvisor;
	import org.farmcode.sodalityLibrary.utils.AsyncMethodAdviceQueuer;
	import org.farmcode.sodalityLibrary.utils.config.adviceTypes.IGetConfigParamAdvice;
	import org.farmcode.sodalityLibrary.utils.config.adviceTypes.ISetConfigParamAdvice;
	import org.farmcode.sodalityLibrary.utils.config.adviceTypes.ISetDefaultConfigParamAdvice;

	public class ConfigAdvisor extends DynamicAdvisor
	{
		override public function set advisorDisplay(value:DisplayObject):void{
			if(super.advisorDisplay && !loaderInfo){
				super.advisorDisplay.removeEventListener(Event.ADDED_TO_STAGE, onAdded);
			}
			super.advisorDisplay = value;
			if(!loaderInfo && super.advisorDisplay){
				if(super.advisorDisplay.stage){
					loaderInfo = super.advisorDisplay.stage.loaderInfo;
				}else{
					super.advisorDisplay.removeEventListener(Event.ADDED_TO_STAGE, onAdded);
				}
			}
		}
		
		public var defaultConfigs:Dictionary = new Dictionary();
		
		private var loaderInfo:LoaderInfo;
		private var pendingAdvice:AsyncMethodAdviceQueuer = new AsyncMethodAdviceQueuer();
		
		[Trigger(type="org.farmcode.sodalityLibrary.triggers.ImmediateAfterTrigger")]
		public function onGetParam(cause:IGetConfigParamAdvice, advice:AsyncMethodAdvice, timing:String):void{
			
			if(loaderInfo){
				var value:* = loaderInfo.parameters[cause.paramName];
				if(!value){
					value = defaultConfigs[cause.paramName];
				}
				cause.value = value;
				advice.adviceContinue();
			}else{
				pendingAdvice.addAdvice(cause,advice,timing,onGetParam);
			}
		}
		[Trigger(triggerTiming="before")]
		public function onSetDefault(cause:ISetDefaultConfigParamAdvice):void{
			defaultConfigs[cause.paramName] = cause.value;
		}
		[Trigger(triggerTiming="before")]
		public function onSetParam(cause:ISetConfigParamAdvice, advice:AsyncMethodAdvice, timing:String):void{
			if(loaderInfo){
				loaderInfo.parameters[cause.paramName] = cause.value;
				advice.adviceContinue();
			}else{
				pendingAdvice.addAdvice(cause,advice,timing,onSetParam);
			}
		}
		
		protected function onAdded(e:Event):void{
			super.advisorDisplay.removeEventListener(Event.ADDED_TO_STAGE, onAdded);
			loaderInfo = super.advisorDisplay.stage.loaderInfo;
			if(loaderInfo){
				pendingAdvice.executePending();
			}
		}
	}
}