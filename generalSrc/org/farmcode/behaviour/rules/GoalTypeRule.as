package org.farmcode.behaviour.rules
{
	import org.farmcode.behaviour.goals.IGoal;
	
	import flash.utils.getQualifiedClassName;
	
	import org.farmcode.reflection.ReflectionUtils;

	public class GoalTypeRule extends SingleItemRule
	{
		[Property(toString="true",clonable="true")]
		public var goalType:Class;
		
		public function GoalTypeRule(){
			super();
		}
		
		public function set goalTypeName(goalTypeName: String): void
		{
			this.goalType = ReflectionUtils.getClassByName(goalTypeName);
		}
		public function get goalTypeName(): String
		{
			return goalType?getQualifiedClassName(this.goalType):null;
		}
		
		override public function goalConcerns(goal:IGoal):Boolean{
			if(!goalType && goalTypeName){
				goalType = ReflectionUtils.getClassByName(goalTypeName);
			}
			return (goalType && goal is goalType);
		}
	}
}