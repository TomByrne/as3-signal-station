package org.farmcode.sodalityPlatformEngine.scene
{
	import org.farmcode.sodalityPlatformEngine.display.popUp.adviceTypes.IFocusOnSceneAdvice;
	import org.farmcode.sodalityPlatformEngine.scene.advice.DisposeSceneAdvice;
	import org.farmcode.sodalityPlatformEngine.scene.advice.SceneRenderAdvice;
	import org.farmcode.sodalityPlatformEngine.scene.adviceTypes.IAddSceneItemAdvice;
	import org.farmcode.sodalityPlatformEngine.scene.adviceTypes.IDisposeSceneAdvice;
	import org.farmcode.sodalityPlatformEngine.scene.adviceTypes.IRetrieveCurrentSceneAdvice;
	import org.farmcode.sodalityPlatformEngine.scene.adviceTypes.ISceneRenderAdvice;
	import org.farmcode.sodalityPlatformEngine.scene.adviceTypes.IShowSceneAdvice;
	
	import flash.display.DisplayObject;
	
	import org.farmcode.core.DelayedCall;
	import org.farmcode.sodality.advice.AsyncMethodAdvice;
	import org.farmcode.sodality.advice.IAdvice;
	import org.farmcode.sodality.advisors.INonVisualAdvisor;
	import org.farmcode.sodality.events.AdviceEvent;
	
	public class SceneAdvisor extends SceneAwareAdvisor
	{
		override public function set advisorDisplay(value:DisplayObject):void{
			super.advisorDisplay = value;
			if(this.currentScene is INonVisualAdvisor){
				(this.currentScene as INonVisualAdvisor).advisorDisplay = this.advisorDisplay
			}
		}
		
		private var renderCall:DelayedCall;
		private var _transitioning: Boolean;
		private var _focused: Boolean;
		private var sceneRenderAdvice:SceneRenderAdvice = new SceneRenderAdvice();
		private var _renderedThisFrame: Boolean;
		
		// NOTE: There is a bug in setting this to true when open an activity, then its help comes up 
		// (because its the first time) then close the game.
		// NOTE: I don't think this is still happening, the helpAdvisor no longer affects renders
		private var _onlyRenderWhenFocused: Boolean;
		
		public function SceneAdvisor(){
						
			this._renderedThisFrame = false;
			
			this._onlyRenderWhenFocused = true;
			this.catchBeforeSceneChange = true;
			this.catchAfterSceneChange = true;
			this.catchAddSceneItemChange = true;
			renderCall = new DelayedCall(this.dispatchRender, 1, false);
		}
		
		protected function set transitioning(value: Boolean): void
		{
			if (value != this.transitioning)
			{
				this._transitioning = value;
				if (this.transitioning)
				{
					this.assessFrameRender();
				}
			}
		}
		protected function get transitioning(): Boolean
		{
			return this._transitioning;
		}
		
		protected function set focused(value: Boolean): void
		{
			if (value != this.focused)
			{
				this._focused = value;
				if (this.focused)
				{
					this.assessFrameRender();
				}
			}
		}
		protected function get focused(): Boolean
		{
			return this._focused;
		}
		
		protected function assessFrameRender(): void
		{
			if (this.allowRender && !this._renderedThisFrame)
			{
				this.dispatchRender();
			}
		}
		
		protected function get allowRender(): Boolean
		{
			return (this.currentScene && !this.transitioning && (this.focused || !this._onlyRenderWhenFocused));
		}
		
		protected function dispatchRender():void
		{
			if (this.allowRender)
			{
				this._renderedThisFrame = true;
				this.renderCall.clear();
				sceneRenderAdvice.scene = this.currentScene;
				dispatchEvent(sceneRenderAdvice);
			}
			else
			{
				this._renderedThisFrame = false;
			}
		}
		
		[Trigger(triggerTiming="after")]
		public function handleSceneFocus( cause: IFocusOnSceneAdvice): void
		{
			if (cause.performFocus && cause.scene == this.currentScene){
				this.focused = cause.focused;
			}
		}
		
		/**
		 * the purpose of this system (avoiding some renders) is to avoid renders getting banked up
		 * in a thread (there should only ever be one render advice in existance).
		 */
		[Trigger(triggerTiming="before")]
		public function onSceneRender(cause: ISceneRenderAdvice):void
		{
			cause.addEventListener(AdviceEvent.COMPLETE, this.handleSceneRenderComplete);
		}
		
		private function handleSceneRenderComplete(event: AdviceEvent): void
		{
			if(!renderCall.running){
				var cause: ISceneRenderAdvice = event.target as ISceneRenderAdvice;
				cause.removeEventListener(AdviceEvent.COMPLETE, this.handleSceneRenderComplete);
				this.renderCall.begin();
			}
		}
		
		override public function onBeforeSceneChange(cause:IShowSceneAdvice, advice:AsyncMethodAdvice,  
			timing:String):void
		{
			// TODO: More reliable way to check if the same scene
			if (this.adviceMatchesCurrentScene(cause))
			{
				cause.aborted = true;
			}
			else
			{
				this.transitioning = true;
				
				this.disposeCurrentScene(advice);
				
				cause.addEventListener(AdviceEvent.CONTINUE, this.handleSceneContinue);
				cause.addEventListener(AdviceEvent.COMPLETE, onSceneChangeComplete);
			}
			
			super.onBeforeSceneChange(cause, advice, timing);
		}
		
		private function onSceneChangeComplete(event: AdviceEvent): void
		{
			var cause: IShowSceneAdvice = event.target as IShowSceneAdvice;
			cause.removeEventListener(AdviceEvent.COMPLETE, this.onSceneChangeComplete);
			
			this.transitioning = false;
			this.dispatchRender();
		}
		
		protected function adviceMatchesCurrentScene(advice: IShowSceneAdvice): Boolean
		{
			var matches: Boolean = false;
			if ((advice.sceneDetailsPath == null && advice.sceneDetails == this.currentScene) ||
				(advice.sceneDetailsPath != null && this._currentSceneDetailsPath == advice.sceneDetailsPath))
			{
				matches = true;
			}
			return matches;
		}
		
		protected function handleSceneContinue(event:AdviceEvent): void
		{
			var cause: IShowSceneAdvice = event.target as IShowSceneAdvice;
			this._currentSceneDetails = cause.sceneDetails;
			if(this.currentScene is INonVisualAdvisor){
				(this.currentScene as INonVisualAdvisor).advisorDisplay = this.advisorDisplay
			}
			this._currentSceneDetailsPath = cause.sceneDetailsPath;
			this.currentScene.init(cause);
		}
				
		[Trigger(triggerTiming="before")]
		public function onCurrentSceneRetrieval(cause: IRetrieveCurrentSceneAdvice):void
		{
			cause.sceneDetails = this._currentSceneDetails;
			cause.sceneDetailsPath = this._currentSceneDetailsPath;
		}
		
		protected function disposeCurrentScene(before:IAdvice = null, after: IAdvice = null): void
		{
			if (this.currentScene != null)
			{
				var dAdvice: DisposeSceneAdvice = new DisposeSceneAdvice(this._currentSceneDetails);
				if (before)
				{
					dAdvice.executeBefore = before;
				}
				else if (after)
				{
					dAdvice.executeAfter = after;
				}
				this.dispatchEvent(dAdvice);				
			}
		}
		
		[Trigger(triggerTiming="before")]
		public function handleSceneDispose(cause: IDisposeSceneAdvice):void
		{
			cause.addEventListener(AdviceEvent.EXECUTE, this.handleDisposeExecute);
		}
		
		protected function handleDisposeExecute(event: AdviceEvent): void
		{
			var cause: IDisposeSceneAdvice = event.target as IDisposeSceneAdvice;
			cause.sceneDetails.scene.dispose(cause);
			if (cause.sceneDetails == this._currentSceneDetails)
			{
				this._currentSceneDetails = null;
			}
			cause.removeEventListener(AdviceEvent.EXECUTE, this.handleDisposeExecute);
		}
		
		override public function onAddSceneItem(cause:IAddSceneItemAdvice, advice:AsyncMethodAdvice, 
			timing:String):void{
			cause.sceneItem.scene = this.currentScene;
			super.onAddSceneItem(cause, advice, timing);
		}
	}
}