package au.com.thefarmdigital.behaviour.rules
{
	import au.com.thefarmdigital.behaviour.BehaviourExecution;
	import au.com.thefarmdigital.behaviour.IBehavingItem;
	import au.com.thefarmdigital.behaviour.goals.IGoal;
	
	public class SingleItemRule extends BehaviourRule implements ISingleItemRule
	{
		[Property(toString="true",clonable="true")]
		public var behaviours:Array;
		
		[Property(toString="true",clonable="true")]
		public function set behavingItem(value:IBehavingItem):void{
			_behavingItem = value;
		}
		public function get behavingItem():IBehavingItem{
			return _behavingItem;
		}
		
		protected var _behavingItem:IBehavingItem;
		
		override public function assessByGoal(goal:IGoal, goals:Array):BehaviourExecution{
			if(goalConcerns(goal) && goal.behavingItem==behavingItem){
				return new BehaviourExecution(this,[goal], this.behaviours);
			}else{
				for each(goal in goals){
					if(goalConcerns(goal) && goal.behavingItem==behavingItem){
						return new BehaviourExecution(this,[goal],this.behaviours);
					}
				}
			}
			return null;
		}
	}
}