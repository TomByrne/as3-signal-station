package org.farmcode.sodalityPlatformEngine.behaviour.advice
{
	import au.com.thefarmdigital.behaviour.IBehavingItem;
	import au.com.thefarmdigital.behaviour.goals.IGoal;
	
	import flash.utils.Dictionary;
	
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodality.advice.IAdvice;
	import org.farmcode.sodalityPlatformEngine.behaviour.adviceTypes.IAddGoalAdvice;

	public class AddGoalAdvice extends AbstractBehaviourAdvice implements IAddGoalAdvice
	{
		[Property(toString="true",clonable="true")]
		public function get goal():IGoal{
			return _goal;
		}
		public function set goal(value:IGoal):void{
			_goal = value;
		}
		[Property(toString="true",clonable="true")]
		public function get goalPath():String{
			return _goalPath;
		}
		public function set goalPath(value:String):void{
			_goalPath = value;
		}
		
		private var _goalPath:String;
		private var _goal:IGoal;
		private var _doRevert: Boolean;
		
		[Property(toString="true",clonable="true")]
		public var goalChanges:Object;
		
		public function AddGoalAdvice(goalPath:String=null, goal:IGoal=null, behavingItemPath:String=null, behavingItem:IBehavingItem=null){
			super(behavingItemPath, behavingItem);
			this.goalPath = goalPath;
			this.goal = goal;
			this._doRevert = true;
		}
		override public function get resolvePaths():Array{
			var ret:Array = super.resolvePaths;
			if(!goal && _goalPath)ret.push(_goalPath);
			return ret;
		}
		override public function set resolvedObjects(value:Dictionary):void{
			super.resolvedObjects = value;
			var goal:IGoal = value[_goalPath];
			if(goal)this.goal = goal;
		}
		override protected function _execute(cause:IAdvice, time:String):void{
			if(goal){
				if(goalChanges){
					for(var i:String in goalChanges){
						goal[i] = goalChanges[i];
					}
				}
				if(behavingItem)goal.behavingItem = behavingItem;
			}
			adviceContinue();
		}
		
		[Property(toString="true",clonable="true")]
		public function get doRevert(): Boolean
		{
			return this._doRevert;
		}
		public function set doRevert(value: Boolean): void
		{
			this._doRevert = value;
		}
		
		public function get revertAdvice(): Advice
		{
			return new RemoveGoalAdvice(_goalPath, this.goal);
		}
	}
}