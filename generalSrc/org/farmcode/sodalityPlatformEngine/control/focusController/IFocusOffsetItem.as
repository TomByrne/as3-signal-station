package org.farmcode.sodalityPlatformEngine.control.focusController
{
	import org.farmcode.sodalityPlatformEngine.control.focusController.IFocusItem;

	public interface IFocusOffsetItem extends IFocusItem
	{
		function get relative():Boolean
		function get focusRatio(): Number; // between 0 and 1
	}
}