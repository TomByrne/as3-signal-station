package org.farmcode.actLibrary.display.transition.actTypes
{
	import flash.display.DisplayObject;
	
	import org.farmcode.actLibrary.display.transition.actTypes.ITransitionAct;
	
	public interface IAdvancedTransitionAct extends ITransitionAct
	{
		function get startDisplay():DisplayObject;
		function get endDisplay():DisplayObject;
		function get transitions():Array;
		function get easing():Function;
	}
}