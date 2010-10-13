package org.tbyrne.core
{
	import org.tbyrne.acting.actTypes.IAct;

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