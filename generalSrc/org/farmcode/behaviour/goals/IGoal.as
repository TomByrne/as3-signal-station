package org.farmcode.behaviour.goals
{
	import org.farmcode.behaviour.IBehavingItem;
	
	import org.farmcode.acting.actTypes.IAct;

	public interface IGoal
	{
		
		/**
		 * handler(from:IGoal)
		 */
		function get goalChanged():IAct;
		function get priority():uint;
		function get progress():Number;
		function get isComplete(): Boolean;
		function get active():Boolean;
		function get behavingItem():IBehavingItem;
		function set behavingItem(value:IBehavingItem):void;
	}
}