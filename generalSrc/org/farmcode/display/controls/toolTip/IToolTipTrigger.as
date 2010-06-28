package org.farmcode.display.controls.toolTip
{
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.display.core.ILayoutView;

	public interface IToolTipTrigger
	{
		/**
		 * handler(from:IToolTipTrigger)
		 */
		function get activeChanged():IAct;
		function get active():Boolean;
		
		/**
		 * handler(from:IToolTipTrigger)
		 */
		function get dataAnchorChanged():IAct;
		function get anchorView():ILayoutView;
		function get anchor():String;
		function get data():*;
		
		/**
		 * Should match a value from ToolTipTypes
		 */
		function get tipType():String;
		
		/**
		 * Some IToolTipManagers use a legend to relate triggers with a legend.
		 * This allows the IToolTipManager to tell the trigger which key has been used.
		 */
		function set annotationKey(value:*):void;
	}
}