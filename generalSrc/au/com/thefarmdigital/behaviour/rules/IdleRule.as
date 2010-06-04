package au.com.thefarmdigital.behaviour.rules
{
	import au.com.thefarmdigital.behaviour.goals.IdleGoal;

	public class IdleRule extends GoalTypeRule
	{
		public function IdleRule(){
			super();
			goalType = IdleGoal;
		}
	}
}