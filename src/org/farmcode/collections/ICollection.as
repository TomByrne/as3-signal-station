package org.farmcode.collections
{
	import org.farmcode.acting.actTypes.IAct;

	public interface ICollection
	{
		/**
		 * handler(from:ICollection, fromX:int, toX:int)
		 */
		function get collectionChanged():IAct;
		function getIterator(): IIterator;
	}
}