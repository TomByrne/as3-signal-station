package au.com.thefarmdigital.behaviour.rules
{
	import au.com.thefarmdigital.behaviour.BehaviourExecution;
	import au.com.thefarmdigital.behaviour.goals.IGoal;
	
	import flash.events.EventDispatcher;
	
	import org.farmcode.hoborg.ReadableObjectDescriber;

	public class BehaviourRule extends EventDispatcher implements IBehaviourRule
	{
		public function get allGoalsConcern():Boolean{
			return false;
		}
		
		public function BehaviourRule(){
			super();
		}
		
		public function goalConcerns(goal:IGoal):Boolean{
			return false;
		}
		
		public function assessByGoal(goal:IGoal, goals:Array):BehaviourExecution{
			return null;
		}
		public function assessByExecution(execution:BehaviourExecution, currentExecutions:Array):BehaviourExecution{
			return null;
		}
		
		override public function toString(): String
		{
			return ReadableObjectDescriber.describe(this);
		}
	}
}