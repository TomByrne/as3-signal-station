package org.tbyrne.behaviour.rules
{
	import org.tbyrne.behaviour.BehaviourExecution;
	import org.tbyrne.behaviour.goals.IGoal;

	public interface IBehaviourRule
	{
		function get allGoalsConcern():Boolean;
		
		function goalConcerns(goal:IGoal):Boolean;
		
		function assessByGoal(goal:IGoal, goals:Array):BehaviourExecution;
		function assessByExecution(execution:BehaviourExecution, currentExecutions:Array):BehaviourExecution;
	}
}