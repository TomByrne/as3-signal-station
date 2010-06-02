package org.farmcode.sodality.advisors
{
	import org.farmcode.sodality.President;
	
	public interface IPresidentAwareAdvisor extends IAdvisor
	{
		function set president(value:President):void;
	}
}