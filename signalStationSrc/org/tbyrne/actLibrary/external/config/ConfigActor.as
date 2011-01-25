package org.tbyrne.actLibrary.external.config
{
	import flash.display.LoaderInfo;
	import flash.utils.Dictionary;
	
	import org.tbyrne.actLibrary.core.UniversalActorHelper;
	import org.tbyrne.actLibrary.external.config.actTypes.IGetConfigParamAct;
	import org.tbyrne.actLibrary.external.config.actTypes.ISetConfigParamAct;
	import org.tbyrne.actLibrary.external.config.actTypes.ISetDefaultConfigParamAct;
	import org.tbyrne.acting.ActingNamspace;
	import org.tbyrne.acting.universal.UniversalActExecution;
	import org.tbyrne.acting.universal.phases.ObjectPhases;
	import org.tbyrne.display.assets.nativeTypes.IStage;
	import org.tbyrne.utils.MethodCallQueue;
	
	use namespace ActingNamspace;

	public class ConfigActor extends UniversalActorHelper
	{
		
		public var defaultConfigs:Dictionary = new Dictionary();
		
		private var loaderInfo:LoaderInfo;
		private var pendingCalls:MethodCallQueue = new MethodCallQueue();
		
		public function ConfigActor(){
			metadataTarget = this;
		}
		public function getParam(paramName:String):*{
			var value:* = loaderInfo.parameters[paramName];
			if(!value){
				value = defaultConfigs[paramName];
			}
			return value;
		}
		
		public var getParamPhases:Array = [ConfigPhases.GET_PARAM];
		public var getParamBeforePhases:Array = [ObjectPhases.REFERENCE_RESOLVED];
		[ActRule(ActClassRule,beforePhases="{getParamBeforePhases}")]
		[ActReaction(phases="{getParamPhases}")]
		public function onGetParam(execution:UniversalActExecution, cause:IGetConfigParamAct):void{
			if(loaderInfo){
				cause.value = getParam(cause.paramName);;
				execution.continueExecution();
			}else{
				pendingCalls.addMethodCall([execution,cause],onGetParam);
			}
		}
		
		public var setDefaultParamPhases:Array = [ConfigPhases.SET_DEFAULT_PARAM];
		[ActRule(ActClassRule)]
		[ActReaction(phases="{setDefaultParamPhases}")]
		public function setDefaultParam(cause:ISetDefaultConfigParamAct):void{
			defaultConfigs[cause.paramName] = cause.value;
		}
		
		public var setParamPhases:Array = [ConfigPhases.SET_PARAM];
		[ActRule(ActClassRule)]
		[ActReaction(phases="{setParamPhases}")]
		public function setParam(execution:UniversalActExecution, cause:ISetConfigParamAct):void{
			if(loaderInfo){
				loaderInfo.parameters[cause.paramName] = cause.value;
				execution.continueExecution();
			}else{
				pendingCalls.addMethodCall([execution,cause],setParam);
			}
		}
		
		
		override protected function setStage(stage:IStage):void{
			super.setStage(stage);
			loaderInfo = (stage?stage.loaderInfo:null);
			if(loaderInfo){
				pendingCalls.executePending();
			}
		}
	}
}