package org.farmcode.debug.data.coreTypes
{
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.display.core.ILayoutView;

	public interface ILayoutViewProvider
	{
		
		/**
		 * handler(from:IDisplayProvider)
		 */
		function get layoutViewChanged():IAct;
		function get layoutView():ILayoutView;
	}
}