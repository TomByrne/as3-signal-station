package org.farmcode.sodalityPlatformEngine.control.adviceTypes
{
	import org.farmcode.sodality.advice.IAdvice;
	import org.farmcode.sodalityPlatformEngine.control.focusController.IFocusItem;

	public interface IAddFocusOffsetItemsAdvice extends IAdvice
	{
		function get focusItem():IFocusItem; // if this is null it will be added to the current item
		function get focusOffsetItems():Array;
	}
}