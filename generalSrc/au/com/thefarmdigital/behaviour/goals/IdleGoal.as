package au.com.thefarmdigital.behaviour.goals
{
	public class IdleGoal extends Goal
	{
		override public function get progress():Number{
			return 0;
		}
		public function IdleGoal(){
			super(0);
		}
		
	}
}