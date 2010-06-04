package org.farmcode.sodalityPlatformEngine.control.adviceTypes
{
	import org.farmcode.sodality.advice.IAdvice;
	import org.farmcode.sodalityPlatformEngine.control.focusController.IFocusItem;

	public interface IRemoveFocusOffsetItemsAdvice extends IAdvice
	{
		function get focusItem():IFocusItem; // if this is null it will be removed from the current item
		function get focusOffsetItems():Array;
	}
}