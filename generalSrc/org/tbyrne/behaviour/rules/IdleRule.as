package org.tbyrne.behaviour.rules
{
	import org.tbyrne.behaviour.goals.IdleGoal;

	public class IdleRule extends GoalTypeRule
	{
		public function IdleRule(){
			super();
			goalType = IdleGoal;
		}
	}
}