package org.farmcode.actLibrary.display.transition.actTypes
{
	import org.farmcode.display.assets.IDisplayAsset;
	
	public interface IAdvancedTransitionAct extends ITransitionAct
	{
		function get startDisplay():IDisplayAsset;
		function get endDisplay():IDisplayAsset;
		function get transitions():Array;
		function get easing():Function;
	}
}