package org.farmcode.collections
{
	import org.farmcode.acting.actTypes.IAct;

	public interface ICollection2D extends ICollection
	{
		/**
		 * handler(from:ICollection, fromX:int, toX:int, fromY:int, toY:int)
		 */
		function get collection2DChanged():IAct;
	}
}