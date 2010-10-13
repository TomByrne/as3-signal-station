package org.tbyrne.behaviour.behaviours
{
	import org.tbyrne.behaviour.goals.IGoal;

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