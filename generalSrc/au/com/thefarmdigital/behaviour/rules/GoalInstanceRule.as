package au.com.thefarmdigital.behaviour.rules
{
	import au.com.thefarmdigital.behaviour.goals.IGoal;

	public class GoalInstanceRule extends SingleItemRule
	{
		[Property(toString="true",clonable="true")]
		public function set goalInstance(value:IGoal):void{
			_goalInstance = value;
		}
		public function get goalInstance():IGoal{
			return _goalInstance;
		}
		
		private var _goalInstance:IGoal;
		
		override public function goalConcerns(goal:IGoal):Boolean{
			return (_goalInstance == goal);
		}
	}
}