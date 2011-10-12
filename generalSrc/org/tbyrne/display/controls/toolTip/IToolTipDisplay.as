package org.tbyrne.display.controls.toolTip
{
	import org.tbyrne.display.core.ILayoutView;

	public interface IToolTipDisplay extends ILayoutView
	{
		function set toolTipData(value:Array):void;
		function set anchor(value:String):void;
		function set anchorView(value:ILayoutView):void;
		function set tipType(value:String):void;
	}
}