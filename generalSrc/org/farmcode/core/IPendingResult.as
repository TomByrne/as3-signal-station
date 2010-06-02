package org.farmcode.core
{
	import org.farmcode.acting.actTypes.IAct;

	public interface IPendingResult{
		/**
		 * handler(pendingResult:IPendingResult)
		 */
		function get success():IAct;
		/**
		 * handler(pendingResult:IPendingResult)
		 */
		function get fail():IAct;
		
		
		function get result():*;
	}
}