package org.farmcode.behaviour.rules
{
	import org.farmcode.behaviour.BehaviourExecution;
	import org.farmcode.behaviour.goals.IGoal;

	public interface IBehaviourRule
	{
		function get allGoalsConcern():Boolean;
		
		function goalConcerns(goal:IGoal):Boolean;
		
		function assessByGoal(goal:IGoal, goals:Array):BehaviourExecution;
		function assessByExecution(execution:BehaviourExecution, currentExecutions:Array):BehaviourExecution;
	}
}