package au.com.thefarmdigital.behaviour.rules
{
	import au.com.thefarmdigital.behaviour.BehaviourExecution;
	import au.com.thefarmdigital.behaviour.goals.IGoal;

	public interface IBehaviourRule
	{
		function get allGoalsConcern():Boolean;
		
		function goalConcerns(goal:IGoal):Boolean;
		
		function assessByGoal(goal:IGoal, goals:Array):BehaviourExecution;
		function assessByExecution(execution:BehaviourExecution, currentExecutions:Array):BehaviourExecution;
	}
}