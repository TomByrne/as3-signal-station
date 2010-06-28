package org.farmcode.display.containers
{
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.display.core.ILayoutView;
	
	public interface ISelectableRenderer extends ILayoutView
	{
		function set selected(value:Boolean):void;
		function get selected():Boolean;
		
		/**
		 * handler(from:ISelectableRenderer)
		 */
		function get selectedChanged():IAct;
	}
}