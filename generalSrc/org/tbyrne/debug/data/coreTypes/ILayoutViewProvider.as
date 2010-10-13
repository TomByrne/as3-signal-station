package org.tbyrne.debug.data.coreTypes
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.display.core.ILayoutView;

	public interface ILayoutViewProvider
	{
		
		/**
		 * handler(from:IDisplayProvider)
		 */
		function get layoutViewChanged():IAct;
		function get layoutView():ILayoutView;
	}
}