package au.com.thefarmdigital.behaviour
{
	import au.com.thefarmdigital.behaviour.behaviours.IBehaviour;
	import au.com.thefarmdigital.behaviour.goals.BinaryGoal;
	import au.com.thefarmdigital.behaviour.goals.IGoal;
	import au.com.thefarmdigital.behaviour.rules.IBehaviourRule;
	import au.com.thefarmdigital.math.StatisticsUtils;
	
	import flash.events.EventDispatcher;
	
	import org.farmcode.hoborg.ReadableObjectDescriber;
	
	[Event(name="executionComplete",type="org.farmcode.sodalityPlatformEngine.behaviour.BehaviourEvent")]
	[Event(name="execute",type="org.farmcode.sodalityPlatformEngine.behaviour.BehaviourEvent")]
	public class BehaviourExecution extends EventDispatcher
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
				this.priority = StatisticsUtils.average(this.goals, "priority");
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
				throw new Error("Cannot remove goal, not present");
			}
		}
		
		public function hasGoal(goal: IGoal): Boolean
		{
			return this.goals.indexOf(goal) >= 0;
		}
		
		public function execute():void{
			if(!_executing){
				_executing = true;
				this.dispatchEvent(new BehaviourEvent(BehaviourEvent.EXECUTE));
				_pendingBehaviours.splice();
				for each(var behaviour:IBehaviour in behaviours){
					var done:Boolean = !behaviour.execute(goals);
					if(!done){
						behaviour.addEventListener(BehaviourEvent.EXECUTION_COMPLETE, onBehaviourComplete);
						_pendingBehaviours.push(behaviour);
					}
				}
				if(!_pendingBehaviours.length){
					dispatchEvent(new BehaviourEvent(BehaviourEvent.EXECUTION_COMPLETE));
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
				execution.addEventListener(BehaviourEvent.EXECUTION_COMPLETE, onDependancyFinish, false, 0, true);
			}
		}
		public function clearDependancies():void{
			for each(var execution:BehaviourExecution in _dependancies){
				execution.removeEventListener(BehaviourEvent.EXECUTION_COMPLETE, onDependancyFinish);
			}
			this._dependancies = new Array();
		}
		protected function onDependancyFinish(e:BehaviourEvent):void{
			var execution:BehaviourExecution = (e.target as BehaviourExecution);
			execution.removeEventListener(BehaviourEvent.EXECUTION_COMPLETE, onDependancyFinish);
			var index:Number = _dependancies.indexOf(e.target);
			if(index!=-1){
				_dependancies.splice(index,1);
			}
			if(!_dependancies.length){
				execute();
			}
		}
		protected function onBehaviourComplete(e:BehaviourEvent):void{
			var behaviour:IBehaviour = (e.target as IBehaviour);
			behaviour.removeEventListener(BehaviourEvent.EXECUTION_COMPLETE, onBehaviourComplete);
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
				dispatchEvent(new BehaviourEvent(BehaviourEvent.EXECUTION_COMPLETE));
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
				behaviour.removeEventListener(BehaviourEvent.EXECUTION_COMPLETE, onBehaviourComplete);
			}
			clearDependancies();
		}
		
		override public function toString(): String
		{
			return ReadableObjectDescriber.describe(this);
		}
	}
}