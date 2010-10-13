package org.tbyrne.collections
{
	import org.tbyrne.acting.actTypes.IAct;

	public interface ICollection2D extends ICollection
	{
		/**
		 * handler(from:ICollection, fromX:int, toX:int, fromY:int, toY:int)
		 */
		function get collection2DChanged():IAct;
	}
}