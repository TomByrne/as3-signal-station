package org.farmcode.behaviour.rules
{
	import org.farmcode.behaviour.goals.IdleGoal;

	public class IdleRule extends GoalTypeRule
	{
		public function IdleRule(){
			super();
			goalType = IdleGoal;
		}
	}
}