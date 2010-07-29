package au.com.thefarmdigital.behaviour
{
	import au.com.thefarmdigital.behaviour.behaviours.IBehaviour;
	import au.com.thefarmdigital.behaviour.goals.IGoal;
	import au.com.thefarmdigital.behaviour.rules.IBehaviourRule;
	
	import flash.utils.Dictionary;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	
	public class BehaviourService
	{
		
		/**
		 * handler(from:BehaviourService, behaviours:Array)
		 */
		public function get behaviourExecute():IAct{
			if(!_behaviourExecute)_behaviourExecute = new Act();
			return _behaviourExecute;
		}
		
		protected var _behaviourExecute:Act;
		
		private var _rules:Array;
		private var _goals:Array;
		private var _goalMapping:Dictionary;
		private var _ruleMapping:Dictionary;
		private var _allGoalRules:Array;
		private var _executingBehaviours:Array;
		private var _restartBehaviours:Array;
		
		public function BehaviourService()
		{
			this._rules = new Array();
			this._goals = new Array();
			this._goalMapping = new Dictionary();
			this._ruleMapping = new Dictionary();
			this._allGoalRules = new Array();
			this._executingBehaviours = new Array();
			this._restartBehaviours = new Array();
		}
		
		public function addRule(rule:IBehaviourRule):void{
			if(_rules.indexOf(rule)==-1){
				_rules.push(rule);
				if(rule.allGoalsConcern){
					_allGoalRules.push(rule);
				}else{
					assessAllGoals(rule);
				}
				searchByRule(rule);
			}
		}
		public function removeRule(rule:IBehaviourRule):void{
			var index:Number = _rules.indexOf(rule);
			if(index!=-1){
				_rules.splice(index,1);
				delete _ruleMapping[rule];
				for each(var map:Array in _goalMapping){
					index = map.indexOf(rule);
					if(index!=-1){
						map.splice(index,1);
					}
				}
			}
			
			// Remove any behaviours that were caused by this rule
			var behIndex: int = this.getRuleExecutionIndex(rule);
			while (behIndex >= 0)
			{
				var beh: BehaviourExecution = this._executingBehaviours[behIndex];
				this._executingBehaviours.splice(behIndex, 1);
				beh.destroy();
				behIndex = this.getRuleExecutionIndex(rule);
			}
		}
		public function addGoal(goal:IGoal):void{
			if(_goals.indexOf(goal)==-1){
				goal.goalChanged.addHandler(onGoalChanged);
				_goals.push(goal);
				assessAllRules(goal);
				searchByGoal(goal);
			}
		}
		public function removeGoal(goal:IGoal):void{
			var index:Number = _goals.indexOf(goal);
			goal.goalChanged.removeHandler(onGoalChanged);
			if(index!=-1){
				_goals.splice(index,1);
				delete _goalMapping[goal];
				for each(var map:Array in _ruleMapping){
					index = map.indexOf(goal);
					if(index!=-1){
						map.splice(index,1);
					}
				}
				
				// Stop dependant behaviours
				for (var i: uint = 0; i < this._executingBehaviours.length; ++i)
				{
					var behaviour: BehaviourExecution = this._executingBehaviours[i];
					if (behaviour.hasGoal(goal))
					{
						behaviour.removeGoal(goal);
					}
				}
			}
		}
		protected function assessAll():void{
			for each(var rule:IBehaviourRule in _rules){
				assessAllGoals(rule);
			}
		}
		protected function assessAllRules(goal:IGoal):void{
			for each(var rule:IBehaviourRule in _rules){
				assessRule(rule,goal);
			}
		}
		protected function assessAllGoals(rule:IBehaviourRule):void{
			for each(var goal:IGoal in _goals){
				assessRule(rule,goal);
			}
		}
		protected function assessRule(rule:IBehaviourRule, goal:IGoal):void{
			if(!rule.allGoalsConcern && rule.goalConcerns(goal)){
				var goalMap:Array = _goalMapping[goal];
				if(!goalMap){
					goalMap = _goalMapping[goal] = [];
				}
				goalMap.push(rule);
				
				var ruleMap:Array = _ruleMapping[goal];
				if(!ruleMap){
					ruleMap = _ruleMapping[rule] = [];
				}
				ruleMap.push(goal);
			}
		}
		protected function onGoalChanged(goal:IGoal):void{
			if(goal.isComplete){
				removeGoal(goal);
			}else{
				searchByGoal(goal);				
			}
		}
		protected function searchByGoal(goal:IGoal):void{
			var goalMap:Array = _goalMapping[goal] || [];
			var rules:Array = goalMap.concat(_allGoalRules);
			for each(var rule:IBehaviourRule in rules){
				searchByRule(rule, goal, goalMap);
			}
		}
		protected function searchByRule(rule:IBehaviourRule, goal:IGoal=null, siblingRules:Array=null, siblingGoals:Array=null):void{
			var ruleMap:Array = rule.allGoalsConcern?_goals:_ruleMapping[rule];
			if(!siblingGoals)siblingGoals = _ruleMapping[rule] || [];
			var execution:BehaviourExecution = rule.assessByGoal(goal,siblingGoals);
			if(!siblingRules)siblingRules = _goalMapping[goal] || [];
			if(execution){
				execution.rule = rule;
				attemptExecution(execution);
			}
		}
		protected function attemptExecution(execution:BehaviourExecution):void{
			var index:int = getRuleExecutionIndex(execution.rule);
			if(index!=-1){
				execution.destroy();
				return;
			}
			var dependant:Boolean = false;
			var cancelBehaviours:Array = [];
			for each (var exec2:BehaviourExecution in _executingBehaviours){
				if(inConflict(execution,exec2)){
					// the behaviours have conflicted, we need to work out who should go first
					if((exec2.executing && !exec2.abortable) || exec2.priority>=execution.priority){
						// the new behaviour must wait for the existing behaviour to finish (even if the existing behaviour is waiting for other behaviours)
						dependant = true;
						execution.addDependancy(exec2);
					}else if(exec2.executing){
						// the existing behaviour will be stopped and will be restarted after the new behaviour
						dependant = true
						// add this reverse dependancy so that the new bahaviour will only begin after the cancellation of the old one is complete
						execution.addDependancy(exec2);
						cancelBehaviours.push(exec2);
					}else{
						// the existing behaviour has already been stopped and will be restarted after the new behaviour
						exec2.addDependancy(execution);
					}
				}
			}
			_executingBehaviours.push(execution);
			// we give this a negative priority to ensure other behaviour remove their dependancies before any executions are restarted.
			execution.executionComplete.addHandler(onExecutionFinished);
			if (dependant)
			{
				execution.executionBegin.addHandler(handleDependantExecute);
			}
			else
			{
				this.performBeginAct(execution.behaviours);
				execution.execute();
			}
			for each(var cancelBeh: BehaviourExecution in cancelBehaviours)
			{
				_restartBehaviours.push(cancelBeh);
				cancelBeh.cancel();
			}
		}
		
		private function handleDependantExecute(exec:BehaviourExecution): void
		{
			exec.executionBegin.removeHandler(handleDependantExecute);
			this.performBeginAct(exec.behaviours);
		}
		
		private function performBeginAct(behaviours: Array): void
		{
			if(_behaviourExecute)_behaviourExecute.perform(this,behaviours);
		}
		
		protected function getRuleExecutionIndex(rule:IBehaviourRule):int{
			for(var i:int=_executingBehaviours.length-1; i>=0; i--){
				var existingExec:BehaviourExecution = _executingBehaviours[i];
				if(existingExec.rule==rule)return i;
			}
			return -1;
		}
		protected function onExecutionFinished(behEx:BehaviourExecution):void{
			behEx.executionComplete.removeHandler(onExecutionFinished);
			
			// remove from executing list
			var index:int = _executingBehaviours.indexOf(behEx);
			if(index!=-1){
				_executingBehaviours.splice(index,1);
			}
			performBeginAct(behEx.behaviours);
			// if this was cancelled to make way for another behaviour, add it back to the queue
			index = _restartBehaviours.indexOf(behEx);
			if(index!=-1){
				_restartBehaviours.splice(index,1);
				attemptExecution(behEx);
			}else{
				behEx.destroy();
			}
		}
		protected function inConflict(exec1:BehaviourExecution, exec2:BehaviourExecution):Boolean{
			var checkedItems:Dictionary = new Dictionary();
			for each(var goal1:IGoal in exec1.goals){
				for each(var goal2:IGoal in exec2.goals){
					if(goal1==goal2){
						return true;
					}
					if(!checkedItems[goal1.behavingItem] && goal1.behavingItem==goal2.behavingItem){
						for each(var beh1:IBehaviour in exec1.behaviours){
							for each(var beh2:IBehaviour in exec2.behaviours){
								if(goal1.behavingItem.behaviourFilter.behavioursConflict(beh1,beh2)){
									return true;
								}
							}
						}
						checkedItems[goal1.behavingItem] = true;
					}
				}
			}
			return false;
		}
	}
}