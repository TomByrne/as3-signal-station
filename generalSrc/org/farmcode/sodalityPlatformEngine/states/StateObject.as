package org.farmcode.sodalityPlatformEngine.states
{
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodality.advice.IAdvice;
	import org.farmcode.sodality.advisors.DynamicAdvisor;
	import org.farmcode.sodality.events.AdvisorEvent;
	import org.farmcode.sodalityLibrary.core.adviceTypes.IRevertableAdvice;
	
	public class StateObject extends DynamicAdvisor
	{
		private var _id:String;
		private var _states:Array;
		private var _currentState:State;
		private var _currentStateId:String;
		private var _previousState:State;
		private var stateObjValid:Boolean = true;
		private var _defaultStateId: String;
		private var pendingBefore:IAdvice;
		private var pendingAfter:IAdvice;
		private var statefulProperties: Array;
		
		public function StateObject(){
			this.statefulProperties = new Array();
			this.registerStatefulProperties();
			this.addEventListener(AdvisorEvent.ADVISOR_ADDED, onAdded);
		}
		
		protected function registerStatefulProperties(): void
		{
			
		}
		
		protected function getStatefulPropertyIndex(propertyId: String): int
		{
			var propIndex: int = -1;
			for (var i: uint = 0; i < this.statefulProperties.length; ++i)
			{
				var testProp: StatefulProperty = this.statefulProperties[i];
				if (testProp.id == propertyId)
				{
					propIndex = i;
				}
			}
			return propIndex;
		}
		
		internal function getStatefulProperty(propertyId: String): StatefulProperty
		{
			var prop: StatefulProperty = null;
			var propIndex: int = this.getStatefulPropertyIndex(propertyId);
			if (propIndex >= 0)
			{
				prop = this.statefulProperties[propIndex];
			}
			return prop;
		}
		
		public function setStatefulPropertyActive(propertyId: String, active: Boolean, 
			before: IAdvice = null, after: IAdvice = null): void
		{
			var prop: StatefulProperty = this.getStatefulProperty(propertyId);
			if (prop == null)
			{
				throw new ArgumentError("StateObject doesn't have stateful property \"" + propertyId + "\"");				
			}
			else if (prop.active != active)
			{
				var oldMap: Dictionary = this.stateActiveMap;
				prop.active = active;
				this.executeStatefulPropDifferences(this.statefulProperties, oldMap, before, after);
			}
		}
		
		protected function get stateActiveMap(): Dictionary
		{
			var map: Dictionary = new Dictionary();
			for (var i: uint = 0; i < this.statefulProperties.length; ++i)
			{
				var prop: StatefulProperty = this.statefulProperties[i];
				map[prop.id] = prop.active;
			}
			return map;
		}
		
		public function hasStatefulProperty(propertyId: String): Boolean
		{
			return this.getStatefulPropertyIndex(propertyId) >= 0;
		}
		
		protected function registerStatefulProperty(propertyId: String, mutable: Boolean = true,
			initalActive: Boolean = true): void
		{
			if (!this.hasStatefulProperty(propertyId))
			{
				var prop: StatefulProperty = new StatefulProperty(propertyId, mutable, initalActive);
				//prop.addEventListener(Event.CHANGE, this.handleStatefulPropertyChange);
				this.statefulProperties.push(prop);
			}
		}
		
		[Property(toString="true",clonable="true")]
		public function get id():String{
			return _id;
		}
		public function set id(value:String):void{
			//if(value!=_id){
				_id = value;
			//}
		}
		public function get states():Array{
			return _states;
		}
		public function set states(value:Array):void{
			if(value!=_states){
				_states = value;
				_currentState = getState(_currentStateId);
			}
		}
		public function get currentState():State{
			if(!stateObjValid){
				stateObjValid = true;
				_currentState = getState(_currentStateId);
			}
			return _currentState;
		}
		
		public function get currentStateId():String{
			return _currentStateId;
		}
		public function set currentStateId(value:String):void{
			if(value!=_currentStateId){
				var prevState:State = _currentState;
				_currentStateId = value;
				stateObjValid = false;
				if(addedToPresident)commitState(prevState);
			}
		}
		public function set defaultStateId(defaultStateId: String): void
		{
			if (this._defaultStateId != defaultStateId)
			{
				this._defaultStateId = defaultStateId;
			}
		}
		public function get defaultStateId(): String{
			return this._defaultStateId;
		}
		
		public function addState(state: State): void
		{
			if (this.states.indexOf(state) < 0)
			{
				var currentEquivalentState: State = this.getState(state.id);
				if (currentEquivalentState != null)
				{
					this.states.splice(this.states.indexOf(currentEquivalentState), 1);
				}
				this.states.push(state);
				if (state.id == this.currentStateId)
				{
					this.commitState(currentEquivalentState);
				}
			}
		}
		
		public function setToDefaultState(before:IAdvice = null, after:IAdvice = null): void
		{
			this.setCurrentState(this.defaultStateId, before, after);
		}
				
		public function setCurrentState(stateId:String, before:IAdvice = null, after:IAdvice = null):void{
			if (stateId != this.currentStateId)
			{
				this._currentStateId = stateId;
				this.stateObjValid = false;
				commitState(_previousState,before,after);
			}
		}
		public function setInitialState(beforeAdvice:IAdvice=null, afterAdvice:IAdvice=null):void{
			commitState(_previousState, beforeAdvice, afterAdvice);
		}
		private function onAdded(e:AdvisorEvent):void{
			if(pendingBefore || pendingAfter)setInitialState(pendingBefore,pendingAfter);
			advisorDisplay.removeEventListener(Event.ADDED_TO_STAGE, onAdded);
		}
		protected function commitState(previousState:State, before:IAdvice=null, after:IAdvice=null):void{
			if(addedToPresident){
				executeDifferences(currentState, previousState, before, after);
				_previousState = currentState;
			}else{
				pendingBefore = before;
				pendingAfter = after;
			}
		}
		
		protected function executeStatefulPropDifferences(stateProps: Array, oldStateMap: Dictionary,
			before: IAdvice = null, after: IAdvice = null): void
		{
			var runActions: Array = new Array();
			
			for (var i: uint = 0; i < this.statefulProperties.length; ++i)
			{
				var prop: StatefulProperty = this.statefulProperties[i];
				if (prop.active != oldStateMap[prop.id])
				{
					var targetState: State = this.currentState;
					while (targetState)
					{
						var adviceList: Array = targetState.getActionsForProperty(prop.id);
						if (adviceList != null)
						{
							for (var j: uint = 0; j < adviceList.length; ++j)
							{
								var targetAdvice: IAdvice = adviceList[j];
								if (prop.active)
								{
									if (!prop.hasActiveAdvice(targetAdvice))
									{
										prop.addActiveAdvice(targetAdvice);
										runActions.push(targetAdvice);
									}
								}
								else
								{
									if (prop.hasActiveAdvice(targetAdvice))
									{
										prop.removeActiveAdvice(targetAdvice);
										var revertableAction: IRevertableAdvice = (targetAdvice as IRevertableAdvice);
										if (revertableAction != null && revertableAction.doRevert)
										{
											var revertAdvice: Advice = revertableAction.revertAdvice;
											runActions.push(revertAdvice);
										}
									}
									else
									{
										throw new Error("WARNING: Trying to revert non active advice");
									}
								}
							}
						}
						targetState = targetState.basedOn;
					}
				}
			}
			
			// Dispatch advice in relevent order
			while (runActions.length > 0)
			{
				var runAction: IAdvice = runActions.pop() as IAdvice;
				if (after)
				{
					runAction.executeAfter = after;
					runAction.executeBefore = null;
				}
				else if(before)
				{
					runAction.executeBefore = before;
					runAction.executeAfter = null;
				}
				else
				{
					runAction.executeBefore = null;
					runAction.executeAfter = null;
				}
				this.dispatchEvent(runAction as Event);
			}
		}
		
		protected function executeDifferences(toState:State, fromState:State, before:IAdvice=null, 
			after:IAdvice=null): void
		{
			// Only process if a change in state
			if(fromState != toState)
			{
				// Find common parent
				var commonParent: State = null;
				if (fromState != null && toState != null)
				{
					var parentState: State = toState;
					while (parentState != null && commonParent == null)
					{
						var fromParentState: State = fromState;
						while (fromParentState != null && commonParent == null)
						{
							if (fromParentState == parentState)
							{
								commonParent = parentState;
							}
							fromParentState = fromParentState.basedOn;
						}
						parentState = parentState.basedOn;
					}
				}
				
				var runActions: Array = new Array();
				
				// Revert from fromState up to commonParent
				if (commonParent != null || toState == null)
				{
					var revFromParentState: State = fromState;
					while (revFromParentState != commonParent)
					{
						for (var j: uint = 0; j < this.statefulProperties.length; ++j)
						{
							var property: StatefulProperty = this.statefulProperties[j];
							var revActions: Array = revFromParentState.getActionsForProperty(property.id);
							if (property.active && revActions != null)
							{
								for (var i: int = revActions.length - 1; i >= 0; i--)
								{
									var revAction: IAdvice = revActions[i];
									if (property.hasActiveAdvice(revAction))
									{
										property.removeActiveAdvice(revAction);
										var revertableAction: IRevertableAdvice = (revAction as IRevertableAdvice);
										if (revertableAction != null && revertableAction.doRevert)
										{
											var revertAdvice: Advice = revertableAction.revertAdvice;
											runActions.push(revertAdvice);
										}
									}
									else
									{
										throw new Error("WARNING: Trying to revert and action not present");
									}
								}
							}
						}
						revFromParentState = revFromParentState.basedOn;
					}
				}
				
				// Construct new state and prepare its deconstruction for later
				if (toState != null)
				{
					var lineage: Array = toState.getLineage(commonParent);
					lineage.reverse();
					for each (var parent: State in lineage)
					{
						for (var n: uint = 0; n < this.statefulProperties.length; ++n)
						{
							var newProp: StatefulProperty = this.statefulProperties[n];
							var newActions: Array = parent.getActionsForProperty(newProp.id);
							if (newActions != null && newProp.active)
							{
								for (var m: uint = 0; m < newActions.length; ++m)
								{
									var newAction: IAdvice = newActions[m];
									if (!newProp.hasActiveAdvice(newAction))
									{
										newProp.addActiveAdvice(newAction);
										runActions.push(newAction);
									}
								}
							}
						}
					}
				}
				
				// Dispatch advise in relevent order
				while (runActions.length > 0)
				{
					var runAction: IAdvice = null;
					if (before)
					{
						runAction = runActions.pop() as IAdvice;
						runAction.executeBefore = before;
						runAction.executeAfter = null;
					}
					else
					{
						runAction = runActions.shift() as IAdvice;
						runAction.executeAfter = after;
						runAction.executeBefore = null;
					}
					this.dispatchEvent(runAction as Event);
				}
			}
		}
		
		protected function getState(id:String):State{
			for each(var state:State in _states){
				if(state.id==id)return state;
			}
			return null;
		}
	}
}