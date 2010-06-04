package org.farmcode.display.controls.toolTip
{
	import org.farmcode.display.core.ILayoutView;

	public interface IToolTipDisplay extends ILayoutView
	{
		function set data(value:*):void;
		function set anchor(value:String):void;
		function set anchorView(value:ILayoutView):void;
		function set tipType(value:String):void;
	}
}