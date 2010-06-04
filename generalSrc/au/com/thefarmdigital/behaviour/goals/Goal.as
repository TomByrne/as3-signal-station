package au.com.thefarmdigital.behaviour.goals
{
	import au.com.thefarmdigital.behaviour.GoalEvent;
	import au.com.thefarmdigital.behaviour.IBehavingItem;
	
	import flash.events.EventDispatcher;
	
	import org.farmcode.hoborg.ReadableObjectDescriber;
	
	[Event(name="goalChanged",type="org.farmcode.sodalityPlatformEngine.behaviour.GoalEvent")]
	public class Goal extends EventDispatcher implements IGoal
	{
		[Property(toString="true",clonable="true")]
		public function get priority():uint{
			return _priority;
		}
		public function set priority(value:uint):void{
			if(_priority != value){
				this.dispatchChangeEvent();
				_priority = value;
			}
		}
		
		[Property(toString="true",clonable="true")]
		public function get active():Boolean{
			return _active;
		}
		public function set active(value:Boolean):void{
			if(_priority != value){
				this.dispatchChangeEvent();
				_active = value;
			}
		}
		
		public function get progress():Number{
			return NaN;
		}
		
		public function get isComplete(): Boolean
		{
			return this.progress >= 1;
		}
		
		[Property(toString="true",clonable="true")]
		public function get behavingItem():IBehavingItem{
			return _behavingItem;
		}
		public function set behavingItem(value:IBehavingItem):void{
			if(_behavingItem != value){
				this.dispatchChangeEvent();
				_behavingItem = value;
			}
		}
		
		private var _priority:uint;
		private var _active:Boolean;
		private var _behavingItem:IBehavingItem;
		
		public function Goal(priority:uint=0){
			this.priority = priority;
		}
		
		protected function dispatchChangeEvent(): void
		{
			this.dispatchEvent(new GoalEvent(GoalEvent.GOAL_CHANGED));
		}
		
		override public function toString(): String
		{
			return ReadableObjectDescriber.describe(this);
		}
	}
}