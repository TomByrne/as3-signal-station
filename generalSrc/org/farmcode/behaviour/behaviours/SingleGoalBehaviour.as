package org.farmcode.behaviour.behaviours
{
	import org.farmcode.behaviour.goals.IGoal;

	public class SingleGoalBehaviour extends RunningBehaviour
	{
		override protected function executeGoals(goals: Array): Boolean
		{
			return executeSingle(goals[0]);
		}
		public function executeSingle(goal:IGoal):Boolean{
			return false;
		}
	}
}