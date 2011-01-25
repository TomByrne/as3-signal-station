package org.tbyrne.actLibrary.display.transition.actTypes
{
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
	
	public interface IAdvancedTransitionAct extends ITransitionAct
	{
		function get startDisplay():IDisplayObject;
		function get endDisplay():IDisplayObject;
		function get transitions():Array;
		function get easing():Function;
	}
}