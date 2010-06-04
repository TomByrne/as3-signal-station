package org.farmcode.display.behaviour.containers
{
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.display.behaviour.ILayoutViewBehaviour;
	
	public interface ISelectableRenderer extends ILayoutViewBehaviour
	{
		function set selected(value:Boolean):void;
		function get selected():Boolean;
		
		/**
		 * handler(from:ISelectableRenderer)
		 */
		function get selectedChanged():IAct;
	}
}