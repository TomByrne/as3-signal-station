package au.com.thefarmdigital.display.controls
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.utils.Dictionary;
	
	/**
	 * The StateControl control adds state managment to controls,
	 * generally, different states mean a different background image
	 * and/or a different font style.
	 */
	public class StateControl extends Control
	{
		protected var states:Dictionary = new Dictionary();
		protected var currentStateList:Array;
		protected var currentState:VisualState;
		protected var stateContainer:Sprite;
		
		public function StateControl(){
			super();
			stateContainer = new Sprite();
			stateContainer.name = "stateContainer";
			addChildAt(stateContainer,0);
			
			// The reason for the below is that by hiding (compiled) states before they've all been 
			// added will stop them all being added.
			for(var i:String in states){
				var state:VisualState = states[i];
				if(state==currentState)showState(state);
				else hideState(state);
			}			
		}
		
		public function addState(state:VisualState):void{
			removeState(state.name);
			states[state.name] = state;
			if(childrenConstructed)hideState(state);
		}
		protected function removeState(name:String):void{
			var state:VisualState = getState(name);
			if(state){
				hideState(state);
				states[name] = null;
			}
		}
		protected function showStateList(stateList:Array):VisualState{
			currentStateList = stateList;
			var state:VisualState;
			for(var i:int=0; i<currentStateList.length && state == null; ++i){
				state = getState(currentStateList[i]);
			}
			if(state && state != this.currentState){
				if(currentState){
					if(childrenConstructed)hideState(currentState);
				}
				currentState = state;
				if(childrenConstructed)showState(currentState);
			}
			return state;
		}
		protected function showState(state:VisualState):void{
			if(state.background){
				if(state.background.parent && state.background.parent!=stateContainer)
				{
					state.background.parent.removeChild(state.background);
				}
				if(!state.background.parent && stateContainer)
				{
					stateContainer.addChild(state.background);
					this.startStateShow(state);
				}
			}
		}
		
		protected function startStateShow(state: VisualState): void
		{
			var cast:MovieClip = state.background as MovieClip;
			if (cast){
				cast.gotoAndPlay(1);
			}
		}
		protected function hideState(state:VisualState):void{
			if(state.background){
				if(state.background.parent)state.background.parent.removeChild(state.background);
				if (state.background is MovieClip)
				{
					var bgClip: MovieClip = state.background as MovieClip;
					bgClip.gotoAndStop(1);
				}
			}
		}
		public function applyState(name: String): void
		{
			var state: VisualState = this.states[name];
			if (state != null)
			{
				this.showState(state);
			}
		}
		public function applyStateList(list: Array): void
		{
			this.showStateList(list);
		}
		public function getState(name:String):VisualState{
			return states[name];
		}
	}
}