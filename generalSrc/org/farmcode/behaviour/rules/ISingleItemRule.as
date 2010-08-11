package org.farmcode.behaviour.rules
{
	import org.farmcode.behaviour.IBehavingItem;
	
	public interface ISingleItemRule extends IBehaviourRule
	{
		function set behavingItem(value:IBehavingItem):void;
		function get behavingItem():IBehavingItem;
	}
}