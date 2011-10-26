package org.tbyrne.geom.rect
{
	import org.tbyrne.acting.actTypes.IAct;

	public interface IRectangleProvider
	{
		
		/**
		 * handler(from:IRectangleProvider)
		 */
		function get rectangleChanged():IAct;
		
		/**
		 * handler(from:IRectangleProvider)
		 */
		function get xChanged():IAct;
		function get x():Number;
		
		/**
		 * handler(from:IRectangleProvider)
		 */
		function get yChanged():IAct;
		function get y():Number;
		
		/**
		 * handler(from:IRectangleProvider)
		 */
		function get widthChanged():IAct;
		function get width():Number;
		
		/**
		 * handler(from:IRectangleProvider)
		 */
		function get heightChanged():IAct;
		function get height():Number;
	}
}