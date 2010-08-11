package org.farmcode.behaviour.goals
{
	import flash.utils.getTimer;
	
	/**
	 * TimeLapseGoal is used when a particular goal should be executed for a particular amount of time.
	 */
	public class TimeLapseGoal extends DestinationGoal
	{
		public function set destinationTime(value:Number):void{
			this.destination = value;
		}
		public function get destinationTime():Number{
			return this.destination;
		}
		public function set timeLapsed(value:Number):void{
			this.value = value;
		}
		public function get timeLapsed():Number{
			return this.value;
		}
		
		public function TimeLapseGoal(priority:uint=1,destinationTime:Number=0){
			super(priority);
			this.value = 0;
			this.destinationTime = destinationTime;
		}
		public function lapseTime(time:Number):void{
			this.value = Math.min(this.destinationTime, this.value + time);
		}
	}
}