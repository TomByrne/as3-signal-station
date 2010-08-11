package org.farmcode.behaviour.rules
{
	import org.farmcode.behaviour.BehaviourExecution;
	import org.farmcode.behaviour.IBehavingItem;
	import org.farmcode.behaviour.goals.IGoal;
	
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