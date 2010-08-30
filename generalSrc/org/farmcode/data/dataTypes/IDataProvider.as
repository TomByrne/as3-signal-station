package org.farmcode.data.dataTypes
{
	public interface IDataProvider
	{
		/**
		 * Should return either an ICollection or an Array.
		 */
		function get data():*
	}
}