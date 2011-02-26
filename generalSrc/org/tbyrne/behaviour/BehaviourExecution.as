package org.tbyrne.behaviour
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.behaviour.behaviours.IBehaviour;
	import org.tbyrne.behaviour.goals.BinaryGoal;
	import org.tbyrne.behaviour.goals.Goal;
	import org.tbyrne.behaviour.goals.IGoal;
	import org.tbyrne.behaviour.rules.IBehaviourRule;
	import org.tbyrne.hoborg.ReadableObjectDescriber;
	
	public class BehaviourExecution
	{
		public function get executing():Boolean{
			return _executing;
		}
		public function get abortable():Boolean{
			for each(var beh:IBehaviour in behaviours){
				if(!beh.abortable)return false;
			}
			return true;
		}
		
		
		/**
		 * handler(from:BehaviourExecution)
		 */
		public function get executionBegin():IAct{
			if(!_executionBegin)_executionBegin = new Act();
			return _executionBegin;
		}
		
		/**
		 * handler(from:BehaviourExecution)
		 */
		public function get executionComplete():IAct{
			if(!_executionComplete)_executionComplete = new Act();
			return _executionComplete;
		}
		
		protected var _executionComplete:Act;
		protected var _executionBegin:Act;
		
		[Property(toString="true",clonable="true")]
		public var rule:IBehaviourRule;
		[Property(toString="true",clonable="true")]
		public var priority:Number;
		[Property(toString="true",clonable="true")]
		public var behaviours:Array;
		
		private var _goals: Array;
		private var _pendingBehaviours:Array;
		private var _executing:Boolean;
		private var _dependancies:Array;
		
		public function BehaviourExecution(rule:IBehaviourRule=null, goals:Array=null, behaviours:Array=null){
			if (goals == null)
			{
				this.goals = null
			}
			else
			{
				this.goals = goals.slice();
			}
			if (behaviours == null)
			{
				this.behaviours = null
			}
			else
			{
				this.behaviours = behaviours.slice();
			}
			this._dependancies = new Array();	
			this._pendingBehaviours = new Array();
		}
		
		[Property(toString="true",clonable="true")]
		public function set goals(value: Array): void
		{
			this._goals = value;
			if (this.goals)
			{
				this.priority = averagePriority(this.goals);
			}
		}
		public function get goals(): Array{
			return this._goals;
		}
		
		public function removeGoal(goal: IGoal): void
		{
			var index: int = this.goals.indexOf(goal);
			if (index >= 0)
			{
				this.goals.splice(index, 1);
				// TODO: How do you know which behaviours are dealing with which goals?
				// Currently skip over this, and only cancel all once no goals left
				if (this.goals.length == 0)
				{
					this.cancel();
				}
			}
			else
			{
				Log.error( "BehaviourExecution.removeGoal: Cannot remove goal, not present");
			}
		}
		
		public function hasGoal(goal: IGoal): Boolean
		{
			return this.goals.indexOf(goal) >= 0;
		}
		
		public function execute():void{
			if(!_executing){
				_executing = true;
				if(_executionBegin)_executionBegin.perform(this);
				_pendingBehaviours.splice();
				for each(var behaviour:IBehaviour in behaviours){
					var done:Boolean = !behaviour.execute(goals);
					if(!done){
						behaviour.executionComplete.addHandler(onBehaviourComplete);
						_pendingBehaviours.push(behaviour);
					}
				}
				if(!_pendingBehaviours.length){
					if(_executionComplete)_executionComplete.perform(this);
				}
			}
		}
		public function cancel():void{
			_executing = false;
			if(_pendingBehaviours.length){
				for each(var beh:IBehaviour in _pendingBehaviours){
					beh.cancel();
				}
			}else{
				checkFinish();
			}
		}
		public function addDependancy(execution:BehaviourExecution):void{
			if(_dependancies.indexOf(execution)==-1){
				_dependancies.push(execution);
				execution.executionComplete.addHandler(onDependancyFinish);
			}
		}
		public function clearDependancies():void{
			for each(var execution:BehaviourExecution in _dependancies){
				execution.executionComplete.removeHandler(onDependancyFinish);
			}
			this._dependancies = new Array();
		}
		protected function onDependancyFinish(execution:BehaviourExecution):void{
			execution.executionComplete.removeHandler(onDependancyFinish);
			var index:Number = _dependancies.indexOf(execution);
			if(index!=-1){
				_dependancies.splice(index,1);
			}
			if(!_dependancies.length){
				execute();
			}
		}
		protected function onBehaviourComplete(behaviour:IBehaviour):void{
			behaviour.executionComplete.removeHandler(onBehaviourComplete);
			for each(var goal:IGoal in goals){
				if(goal is BinaryGoal){
					(goal as BinaryGoal).done = true;
				}
			}
			var index:Number = _pendingBehaviours.indexOf(behaviour);
			if(index!=-1){
				_pendingBehaviours.splice(index,1);
			}
			checkFinish();
		}
		protected function checkFinish():void{
			if(!_pendingBehaviours.length){
				this.finishAll();
				clearDependancies();
				if(_executionComplete)_executionComplete.perform(this);
			}
		}
		protected function finishAll(): void
		{
			for each(var behavior:IBehaviour in behaviours){
				behavior.finish();
			}
		}
		
		public function destroy():void{
			_executing = false;
			goals = [];
			while (this.behaviours.length > 0)
			{
				var behaviour: IBehaviour = this.behaviours.pop() as IBehaviour;
				behaviour.executionComplete.removeHandler(onBehaviourComplete);
			}
			clearDependancies();
		}
		
		public function toString(): String
		{
			return ReadableObjectDescriber.describe(this);
		}
		
		protected static function averagePriority(items: Array): Number
		{
			var priority: Number = 0;
			for each(var goal:Goal in items){
				priority += goal.priority;
			}
			return priority/items.length;
		}
	}
}