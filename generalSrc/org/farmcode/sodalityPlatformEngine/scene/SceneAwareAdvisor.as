package org.farmcode.sodalityPlatformEngine.scene
{
	import org.farmcode.sodality.TriggerTiming;
	import org.farmcode.sodality.advice.AsyncMethodAdvice;
	import org.farmcode.sodality.advisors.DynamicAdvisor;
	import org.farmcode.sodality.events.AdviceEvent;
	import org.farmcode.sodality.events.AdvisorEvent;
	import org.farmcode.sodality.events.DynamicAdvisorEvent;
	import org.farmcode.sodality.triggers.AdviceClassTrigger;
	import org.farmcode.sodality.triggers.IAdviceTrigger;
	import org.farmcode.sodalityLibrary.external.siteStream.advice.SiteStreamResolveAdvice;
	import org.farmcode.sodalityPlatformEngine.scene.advice.AddSceneItemAdvice;
	import org.farmcode.sodalityPlatformEngine.scene.advice.RemoveSceneItemAdvice;
	import org.farmcode.sodalityPlatformEngine.scene.advice.RetrieveCurrentSceneAdvice;
	import org.farmcode.sodalityPlatformEngine.scene.adviceTypes.IAddSceneItemAdvice;
	import org.farmcode.sodalityPlatformEngine.scene.adviceTypes.IRemoveSceneItemAdvice;
	import org.farmcode.sodalityPlatformEngine.scene.adviceTypes.IShowSceneAdvice;
	
	
	/**
	 * An abstract class allowing you to easily hook into common scene related advice.
	 * Be sure to set the appropriate booleans to catch the right advice
	 * (i.e. catchBeforeSceneChange, catchAfterSceneChange, catchAddSceneItem,
	 * catchRemoveSceneItem). If neither catchBeforeSceneChange or catchAfterSceneChange
	 * are set to true then the currentSceneDetails and currentSceneDetailsPath
	 * will not be updated.
	 * 
	 */
	public class SceneAwareAdvisor extends DynamicAdvisor
	{
		public function get catchBeforeSceneChange():Boolean{
			return _catchBeforeSceneChange;
		}
		public function set catchBeforeSceneChange(value:Boolean):void{
			if(_catchBeforeSceneChange != value){
				_catchBeforeSceneChange = value;
				assessTriggers();
			}
		}
		public function get catchAfterSceneChange():Boolean{
			return _catchAfterSceneChange;
		}
		public function set catchAfterSceneChange(value:Boolean):void{
			if(_catchAfterSceneChange != value){
				_catchAfterSceneChange = value;
				assessTriggers();
			}
		}
		public function get catchAddSceneItemChange():Boolean{
			return _catchAddSceneItemChange;
		}
		public function set catchAddSceneItemChange(value:Boolean):void{
			if(_catchAddSceneItemChange != value){
				_catchAddSceneItemChange = value;
				assessTriggers();
			}
		}
		public function get catchRemoveSceneItemChange():Boolean{
			return _catchRemoveSceneItemChange;
		}
		public function set catchRemoveSceneItemChange(value:Boolean):void{
			if(_catchRemoveSceneItemChange != value){
				_catchRemoveSceneItemChange = value;
				assessTriggers();
			}
		}
		
		public function get currentSceneDetails():SceneDetails{
			return _currentSceneDetails;
		}
		public function set currentSceneDetails(value:SceneDetails):void{
			_currentSceneDetails = value;
		}
		public function get currentSceneDetailsPath():String{
			return _currentSceneDetailsPath;
		}
		public function set currentSceneDetailsPath(value:String):void{
			_currentSceneDetailsPath = value;
		}
		
		private var _catchBeforeSceneChange:Boolean;
		private var _catchAfterSceneChange:Boolean;
		private var _catchAddSceneItemChange:Boolean;
		private var _catchRemoveSceneItemChange:Boolean;
		
		private var catchBeforeTrigger:IAdviceTrigger;	
		private var catchAfterTrigger:IAdviceTrigger;	
		private var catchAddTrigger:IAdviceTrigger;	
		private var catchRemoveTrigger:IAdviceTrigger;
		
		protected var _currentSceneDetails:SceneDetails;
		protected var _currentSceneDetailsPath:String;
		
		public function SceneAwareAdvisor(){
			catchBeforeTrigger = new AdviceClassTrigger(IShowSceneAdvice,[new AsyncMethodAdvice(this,"onBeforeSceneChange")],TriggerTiming.BEFORE);
			catchAfterTrigger = new AdviceClassTrigger(IShowSceneAdvice,[new AsyncMethodAdvice(this,"onAfterSceneChange")],TriggerTiming.AFTER);
			catchAddTrigger = new AdviceClassTrigger(IAddSceneItemAdvice,[new AsyncMethodAdvice(this,"onAddSceneItem")],TriggerTiming.AFTER);
			catchRemoveTrigger = new AdviceClassTrigger(IRemoveSceneItemAdvice,[new AsyncMethodAdvice(this,"onRemoveSceneItem")],TriggerTiming.AFTER);
			this.addEventListener(AdvisorEvent.ADVISOR_ADDED, onAdvisorAdded);
		}
		protected function onAdvisorAdded(event:AdvisorEvent):void{
			if(_catchBeforeSceneChange || _catchAfterSceneChange){
				retrieveScene();
			}else{
				trace("WARNING: SceneAwareAdvisor doesn't catch scene (use catchBeforeSceneChange or catchAfterSceneChange)");
			}
		}
		
		protected function get currentScene(): IScene {
			var s: IScene = null;
			if (this._currentSceneDetails) {
				s = this._currentSceneDetails.scene;
			}
			return s;
		}
		
		protected function assessTriggers():void{
			triggers = [];
			if(_catchBeforeSceneChange)triggers.push(catchBeforeTrigger);
			if(_catchAfterSceneChange)triggers.push(catchAfterTrigger);
			if(_catchAddSceneItemChange)triggers.push(catchAddTrigger);
			if(_catchRemoveSceneItemChange)triggers.push(catchRemoveTrigger);
			if(addedToPresident){
				dispatchEvent(DynamicAdvisorEvent(DynamicAdvisorEvent.TRIGGERS_CHANGED));
			}
		}
		protected function retrieveScene():void{
			var sceneAdvice:RetrieveCurrentSceneAdvice = new RetrieveCurrentSceneAdvice();
			sceneAdvice.addEventListener(AdviceEvent.COMPLETE, onSceneRetrieved);
			dispatchEvent(sceneAdvice);
		}
		protected function onSceneRetrieved(event:AdviceEvent):void{
			var sceneAdvice:RetrieveCurrentSceneAdvice = event.target as RetrieveCurrentSceneAdvice;
			sceneAdvice.removeEventListener(AdviceEvent.CONTINUE, onSceneRetrieved);
			currentSceneDetails = sceneAdvice.sceneDetails;
			currentSceneDetailsPath = sceneAdvice.sceneDetailsPath;
		}
		
		// advice handlers
		public function onBeforeSceneChange(cause:IShowSceneAdvice, advice:AsyncMethodAdvice, timing:String):void{
			if(!cause.aborted){
				currentSceneDetails = cause.sceneDetails;
				currentSceneDetailsPath = cause.sceneDetailsPath;
			}
			advice.adviceContinue();
		}
		public function onAfterSceneChange(cause:IShowSceneAdvice, advice:AsyncMethodAdvice, timing:String):void{
			currentSceneDetails = cause.sceneDetails;
			currentSceneDetailsPath = cause.sceneDetailsPath;
			advice.adviceContinue();
		}
		public function onAddSceneItem(cause:IAddSceneItemAdvice, advice:AsyncMethodAdvice, timing:String):void{
			advice.adviceContinue();
		}
		public function onRemoveSceneItem(cause:IRemoveSceneItemAdvice, advice:AsyncMethodAdvice, timing:String):void{
			advice.adviceContinue();
		}
		
		// shortcut functions
		protected function addSceneItem(item:ISceneItem):void{
			var advice:AddSceneItemAdvice = new AddSceneItemAdvice(null,item);
			dispatchEvent(advice);
		}
		protected function removeSceneItem(item:ISceneItem):void{
			var advice:RemoveSceneItemAdvice = new RemoveSceneItemAdvice(null,item);
			dispatchEvent(advice);
		}
		protected function retrieveItem(itemPath:String, completeHandler:Function):void{
			var advice:SiteStreamResolveAdvice = new SiteStreamResolveAdvice(itemPath);
			advice.addEventListener(AdviceEvent.COMPLETE, completeHandler);
			dispatchEvent(advice);
		}
	}
}