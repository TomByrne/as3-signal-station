package org.tbyrne.actLibrary.display.transition.actTypes
{
	import org.tbyrne.display.assets.assetTypes.IDisplayAsset;
	
	public interface IAdvancedTransitionAct extends ITransitionAct
	{
		function get startDisplay():IDisplayAsset;
		function get endDisplay():IDisplayAsset;
		function get transitions():Array;
		function get easing():Function;
	}
}