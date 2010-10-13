package org.tbyrne.display.containers.accordionGrid
{
	public interface IAccordionGridDataProvider
	{
		/**
		 * accordionData should return an ICollection (or Array) of
		 * data objects representing each of the accordion panels.
		 */
		function get accordionData():*;
		/**
		 * gridData should return an ICollection2D of objects, including
		 * the objects from accordionData. Each time one of the accordion data
		 * items is reached, it is considered the parent of all following data
		 * items until another accordion data item is reached.
		 */
		function get gridData():*;
	}
}