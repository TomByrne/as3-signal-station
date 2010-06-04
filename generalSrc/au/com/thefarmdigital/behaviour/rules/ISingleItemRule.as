package au.com.thefarmdigital.behaviour.rules
{
	import au.com.thefarmdigital.behaviour.IBehavingItem;
	
	public interface ISingleItemRule extends IBehaviourRule
	{
		function set behavingItem(value:IBehavingItem):void;
		function get behavingItem():IBehavingItem;
	}
}