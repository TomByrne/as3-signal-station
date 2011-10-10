package org.tbyrne.tbyrne.composeLibrary.types.display2D
{
	import org.tbyrne.acting.actTypes.IAct;

	public interface IRectangleTrait
	{
		/**
		 * handler(from:IRectangleTrait)
		 */
		function get rectangleChanged():IAct;
		
		/**
		 * handler(from:IRectangleTrait)
		 */
		function get position2dChanged():IAct;
		function get x():Number;
		function get y():Number;
		
		/**
		 * handler(from:IRectangleTrait)
		 */
		function get size2dChanged():IAct;
		function get width():Number;
		function get height():Number;
	}
}