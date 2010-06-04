package au.com.thefarmdigital.behaviour.goals
{
	import au.com.thefarmdigital.behaviour.GoalEvent;
	
	/**
	 * DestinationGoal is used when a particular goal is only complete when a numerical value is reached.
	 */
	public class DestinationGoal extends Goal
	{
		[Property(toString="true",clonable="true")]
		public function set destination(value:Number):void{
			if(_destination != value){
				_destination = value;
				dispatchEvent(new GoalEvent(GoalEvent.GOAL_CHANGED));
			}
		}
		public function get destination():Number{
			return _destination;
		}
		
		[Property(toString="true",clonable="true")]
		public function set value(value:Number):void{
			if(isNaN(startValue))startValue = value;
			if(_value != value){
				_value = value;
				dispatchEvent(new GoalEvent(GoalEvent.GOAL_CHANGED));
			}
		}
		public function get value():Number{
			return _value;
		}
		override public function get progress():Number{
			if(isNaN(startValue))return 0;
			else if(startValue==_destination)return 1;
			else return Math.min(Math.max(0,Math.abs((_value-startValue)/(_destination-startValue))),1);
		}
		
		private var _destination:Number=0;
		private var _value:Number=0;
		protected var startValue:Number;
		
		public function DestinationGoal(priority:uint=1, destination:Number=0){
			super(priority);
			this.destination = destination;
		}
		
	}
}