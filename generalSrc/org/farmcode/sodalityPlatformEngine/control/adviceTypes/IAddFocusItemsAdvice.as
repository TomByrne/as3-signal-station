package org.farmcode.sodalityPlatformEngine.control.adviceTypes
{
	import org.farmcode.sodality.advice.IAdvice;

	public interface IAddFocusItemsAdvice extends IAdvice
	{
		function get focusItems():Array;
	}
}