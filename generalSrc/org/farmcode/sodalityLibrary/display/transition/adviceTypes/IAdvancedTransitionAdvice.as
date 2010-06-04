package org.farmcode.sodalityLibrary.display.transition.adviceTypes
{
	import org.farmcode.sodalityLibrary.display.transition.adviceTypes.ITransitionAdvice;
	
	import flash.display.DisplayObject;
	
	public interface IAdvancedTransitionAdvice extends ITransitionAdvice
	{
		function get startDisplay():DisplayObject;
		function get endDisplay():DisplayObject;
		function get transitions():Array;
		function get easing():Function;
	}
}