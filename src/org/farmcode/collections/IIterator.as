package org.farmcode.collections
{
	public interface IIterator
	{
		/**
		 * Iterates and returns the current value. The first time this is called
		 * it should return the first item.
		 */
		function next():*;
		/**
		 * Returns the current item. If this is called before next() it should
		 * return null.
		 */
		function current():*;
		/**
		 * Resets the iterator.
		 */
		function reset():void;
		/**
		 * Release the iterator.
		 */
		function release():void;
		/**
		 * the current index of the iterator.
		 */
		function get x():int;
	}
}