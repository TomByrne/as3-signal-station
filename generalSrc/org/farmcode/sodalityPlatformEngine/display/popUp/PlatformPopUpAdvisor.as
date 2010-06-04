package org.farmcode.sodalityPlatformEngine.display.popUp
{
	import au.com.thefarmdigital.display.popUp.PopUpEvent;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import org.farmcode.hoborg.Cloner;
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodality.advice.AsyncMethodAdvice;
	import org.farmcode.sodality.advice.IAdvice;
	import org.farmcode.sodality.events.AdviceEvent;
	import org.farmcode.sodalityLibrary.core.adviceTypes.IRevertableAdvice;
	import org.farmcode.sodalityLibrary.display.popUp.PopUpAdvisor;
	import org.farmcode.sodalityLibrary.display.popUp.advice.RemovePopUpAdvice;
	import org.farmcode.sodalityLibrary.display.popUp.adviceTypes.IAddPopUpAdvice;
	import org.farmcode.sodalityLibrary.display.popUp.adviceTypes.IAdvancedAddPopUpAdvice;
	import org.farmcode.sodalityLibrary.display.popUp.adviceTypes.IRemovePopUpAdvice;
	import org.farmcode.sodalityPlatformEngine.core.adviceTypes.IApplicationInitAdvice;
	import org.farmcode.sodalityPlatformEngine.display.popUp.advice.FocusOnSceneAdvice;
	import org.farmcode.sodalityPlatformEngine.display.popUp.adviceTypes.IFocusOnSceneAdvice;
	import org.farmcode.sodalityPlatformEngine.display.popUp.adviceTypes.IPlatformAddPopUpAdvice;
	import org.farmcode.sodalityPlatformEngine.display.popUp.adviceTypes.IRemoveFocusedPopUpAdvice;
	import org.farmcode.sodalityPlatformEngine.scene.IScene;
	import org.farmcode.sodalityPlatformEngine.scene.advice.SceneRenderAdvice;
	import org.farmcode.sodalityPlatformEngine.scene.adviceTypes.ISceneRenderAdvice;
	import org.farmcode.sodalityPlatformEngine.scene.adviceTypes.IShowSceneAdvice;

	public class PlatformPopUpAdvisor extends PopUpAdvisor
	{
		public var defaultSceneAdvice:IAdvice;
		
		private var modalPopUps:Array;
		private var currentScene:IScene;
		private var _sceneInFocus:Boolean;
		private var focusedPopUp:DisplayObject;
		private var executingAdvice:Array;
		private var revertAdvice:Array;
		private var beforeAdvice:IAdvice;
		private var focusAdviceMap:Dictionary;
		private var pendingFocusCommits: Array;
		private var pendingRender:Advice;
		
		public function PlatformPopUpAdvisor(){
			super();
			
			this.pendingFocusCommits = new Array();
				
			this.executingAdvice = new Array();
			this.focusAdviceMap = new Dictionary();
			
			this.modalPopUps = new Array();
			this.revertAdvice = new Array();
			
			this._sceneInFocus = true;
			popUpManager.addEventListener(PopUpEvent.FOCUS_CHANGE, onFocusChange);
		}
		
		protected function setSceneInFocus(value: Boolean, before: IAdvice = null): void
		{
			if (value != this.sceneInFocus)
			{
				this._sceneInFocus = value;
				if (this.currentScene != null)
				{
					if (this.sceneInFocus)
					{
						this.executeAdviceList(null);
					}
					this.requestSceneFocus(before);
				}
			}
		}
		protected function get sceneInFocus(): Boolean
		{
			return this._sceneInFocus;
		}
		
		protected function onFocusChange(e:PopUpEvent):void{
			if(e.popUpDisplay){
				focusedPopUp = e.popUpDisplay;
				this.executeAdviceList(focusAdviceMap[e.popUpDisplay]);
			}else{
				focusedPopUp = null;
			}
		}
		[Trigger(triggerTiming="after")]
		public function onApplicationInit(cause:IApplicationInitAdvice):void{
			if(!focusedPopUp && !currentScene && defaultSceneAdvice){
				defaultSceneAdvice.executeAfter = cause;
				dispatchEvent(defaultSceneAdvice as Event);
			}
		}
		
		[Trigger(triggerTiming="before")]
		public function onRender( cause: ISceneRenderAdvice, advice:AsyncMethodAdvice, timing:String):void{
			if(modalPopUps.length>0 && (cause.advisor!=this) && !cause.forceRender){
				continueRender();
				pendingRender = advice;
				pendingRender.addEventListener(AdviceEvent.CONTINUE, onPendingContinue);
			}else{
				advice.adviceContinue();
			}
		}
		public function continueRender():void{
			if(pendingRender){
				pendingRender.removeEventListener(AdviceEvent.CONTINUE, onPendingContinue);
				pendingRender.adviceContinue();
				pendingRender = null;
			}
		}
		public function onPendingContinue( e:AdviceEvent):void{
			pendingRender.removeEventListener(AdviceEvent.CONTINUE, onPendingContinue);
			pendingRender = null;
		}
		
		
		[Trigger(triggerTiming="before")]
		public function onSceneChange( cause:IShowSceneAdvice):void
		{
			if (!cause.aborted){
				cause.addEventListener(AdviceEvent.CONTINUE, this.handleSceneContinue);
			}
		}
		
		protected function handleSceneContinue(event: AdviceEvent): void
		{
			// TODO: Should remove focussed of old scene during the scene disposed advice 
			
			var cause: IShowSceneAdvice = event.target as IShowSceneAdvice;
			cause.removeEventListener(AdviceEvent.CONTINUE, this.handleSceneContinue);
			 
			this.currentScene = cause.sceneDetails.scene;
			
			if (this.currentScene){
				listenToAdvice(cause);
				this.requestSceneFocus(cause);
			}
		}
		
		private function requestSceneFocus(before: IAdvice = null): void
		{
			//this.currentScene.setFocused(this.sceneInFocus, before, after);
			var advice: FocusOnSceneAdvice = new FocusOnSceneAdvice(this.sceneInFocus, this.currentScene);
			var after: IAdvice = this.lastExecutingAdvice;
			if (after == null && this.pendingFocusCommits.length > 0){
				after = this.pendingFocusCommits[this.pendingFocusCommits.length - 1];
			}
			advice.executeBefore = before;
			advice.executeAfter = after;
			
			advice.addEventListener(AdviceEvent.EXECUTE, doSceneFocus);
			
			this.cancelPendingFocusAdvice();			
			this.pendingFocusCommits.push(advice);
			listenToAdvice(advice);
						
			this.dispatchEvent(advice);
		}
		
		private function cancelPendingFocusAdvice(): void
		{
			for each (var pFocusAdvice: FocusOnSceneAdvice in this.pendingFocusCommits)
			{
				pFocusAdvice.performFocus = false;
			}
		}
		
		public function doSceneFocus(e:AdviceEvent): void
		{
			var cause: IFocusOnSceneAdvice = (e.target as IFocusOnSceneAdvice)
			
			if (cause.performFocus && cause.focused == this.sceneInFocus && cause.scene == this.currentScene)
			{
				this.currentScene.setFocused(cause.focused, cause);
			}
			
			var pendingIndex: int = -1;
			for (var i: uint = 0; i < this.pendingFocusCommits.length && pendingIndex < 0; ++i)
			{
				 var pFocusAdvice: FocusOnSceneAdvice = this.pendingFocusCommits[i];
				 if (Cloner.areClones(pFocusAdvice, cause))
				 {
				 	pendingIndex = i;
				 }
			}
			if (pendingIndex >= 0)
			{
				this.pendingFocusCommits.splice(pendingIndex, 1);
			}
			else
			{
				trace("WARNING: Trying to commit non-registered focus advice");
			}
		}
		
		protected function executeAdviceList(adviceList:Array):void{
			var runAdvice: Array = new Array();
			
			// Process reverting
			while (this.revertAdvice.length > 0)
			{
				var revAdvice: IRevertableAdvice = this.revertAdvice.shift() as IRevertableAdvice;
				var revert:IAdvice = revAdvice.revertAdvice;
				if(revAdvice.doRevert && revert){
					runAdvice.push(revert);
				}
			}
			
			// Process new
			if(adviceList){
				for each(var advice:IAdvice in adviceList){
					runAdvice.push(advice);
					if(advice is IRevertableAdvice){
						revertAdvice.push(advice);
					}
				}
			}
			
			var afterAdvice: IAdvice = this.lastExecutingAdvice;
			while (runAdvice.length > 0)
			{
				var toRun: IAdvice = null;
				if (afterAdvice || !this.beforeAdvice)
				{
					toRun = runAdvice.shift() as IAdvice;
				}
				else
				{
					toRun = runAdvice.pop() as IAdvice;
				}
				this.executeAdvice(toRun, this.beforeAdvice, afterAdvice);
			}
		}
		
		protected function get lastExecutingAdvice(): IAdvice
		{
			return executingAdvice[executingAdvice.length-1];
		}
		
		protected function executeAdvice(advice:IAdvice, before:IAdvice, after:IAdvice):void{
			advice.executeAfter = after;
			advice.executeBefore = after?null:before;
			listenToAdvice(advice);
			dispatchEvent(advice as Event);
		}
		protected function listenToAdvice(advice:IAdvice):void{
			advice.addEventListener(AdviceEvent.COMPLETE, onFocusAdviceContinue);
			executingAdvice.push(advice);
		}
		
		protected function onFocusAdviceContinue(e:AdviceEvent):void{
			var advice:IAdvice = (e.target as Advice);
			for(var i:int=0; i<executingAdvice.length; ++i){
				var compAdvice:IAdvice = executingAdvice[i];
				if(compAdvice==advice || Cloner.areClones(compAdvice,advice)){
					executingAdvice.splice(i,1);
					break;
				}
			}
		}
				
		[Trigger(triggerTiming="before")]
		override public function onBeforeAddPopUp(cause:IAddPopUpAdvice):void
		{
			var castCause:IPlatformAddPopUpAdvice = (cause as IPlatformAddPopUpAdvice);
			var advancedCause: IAdvancedAddPopUpAdvice = cause as IAdvancedAddPopUpAdvice;
			var focusable: Boolean = (advancedCause == null || advancedCause.focusable);
			if(castCause && focusable){
				focusAdviceMap[castCause.display] = castCause.focusAdvice?castCause.focusAdvice:[];
			}
			if(cause.modal && modalPopUps.indexOf(cause.display)==-1){
				modalPopUps.push(cause.display);
			}
			if (focusable)
			{
				// About to add a popup which will hide scene, so set it unfocussed
				this.setSceneInFocus(false, cause);
				continueRender()
			}
			super.onBeforeAddPopUp(cause);
		}
		
		override protected function onRemovePopUp(e:AdviceEvent):void
		{
			this.beforeAdvice = (e.target as IRemovePopUpAdvice);
			super.onRemovePopUp(e);
			this.beforeAdvice = null;
		}
		
		[Trigger(triggerTiming="before")]
		override public function onBeforeRemovePopUp(cause:IRemovePopUpAdvice):void
		{
			var index:Number = modalPopUps.indexOf(cause.display);
			if(index!=-1)modalPopUps.splice(index,1);
			
			// Handle remove popup which causes scene to be focused
			// TODO: this could cause a bug if the advice's focusable prop has change since adding
			if (this.popUpManager.isFocusable(cause.display))
			{
				if(focusAdviceMap[cause.display]){
					delete focusAdviceMap[cause.display];
				}
				
				if (!this.hasFocusPopups() && this.popUpManager.isManaging(cause.display))
				{
					if(currentScene){
						this.setSceneInFocus(true, cause);
						
						// Popup manager is about to focus on the scene
						var renderAdvice:SceneRenderAdvice = new SceneRenderAdvice(this.currentScene);
						renderAdvice.forceRender = true;
						
						this.executeAdvice(renderAdvice, cause, null);
					}else if(defaultSceneAdvice){
						defaultSceneAdvice.executeAfter = cause;
						dispatchEvent(defaultSceneAdvice as Event);
					}
					
					cause.addEventListener(AdviceEvent.EXECUTE, this.onRemovePopUp);
				} 
				else
				{
					// MERGE DIF:this.setSceneInFocus(false, advice);
					this.setSceneInFocus(false, cause);
					super.onBeforeRemovePopUp(cause);
				}
			}
			else
			{
				super.onBeforeRemovePopUp(cause);
			}
		}
		
		[Trigger(triggerTiming="before")]
		public function onRemoveFocusedPopUp( cause: IRemoveFocusedPopUpAdvice):void{
			if(focusedPopUp){
				var removeAdvice:RemovePopUpAdvice = new RemovePopUpAdvice(null, this.focusedPopUp);
				// MERGE DIF: removeAdvice.executeAfter = advice;
				removeAdvice.executeBefore = cause;
				dispatchEvent(removeAdvice);
			}else{
				cause.aborted = true;
			}
		}
		
		
		/*
		 used to use popUpManager.numFocusablePopups but it is unreliable if a new
		 popup has hit onBeforeAddPopUp but has not yet been added.
		*/
		protected function hasFocusPopups():Boolean{
			for(var i:* in focusAdviceMap){
				return true;
			}
			return false;
		}
	}
}