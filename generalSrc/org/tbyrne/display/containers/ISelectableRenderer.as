package org.tbyrne.display.containers
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.display.core.ILayoutView;
	
	public interface ISelectableRenderer extends ILayoutView
	{
		function set selectedIndices(value:Array):void;
		
		function set selected(value:Boolean):void;
		function get selected():Boolean;
		
		/**
		 * handler(from:ISelectableRenderer)
		 */
		function get selectedChanged():IAct;
	}
}