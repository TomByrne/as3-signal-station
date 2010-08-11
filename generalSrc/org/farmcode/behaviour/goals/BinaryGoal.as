package org.farmcode.behaviour.goals
{
	/**
	 * BinaryGoal is used when a particular goal is either executed or not (as opposed to having levels of completion).
	 */
	public class BinaryGoal extends Goal
	{
		public function set done(value:Boolean):void{
			_done = value;
		}
		public function get done():Boolean{
			return _done;
		}
		override public function get progress():Number{
			return _done?1:0;
		}
		
		private var _done:Boolean;
		
		public function BinaryGoal(priority:uint){
			super(priority);
		}
		
	}
}