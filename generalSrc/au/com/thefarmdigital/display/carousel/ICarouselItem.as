package au.com.thefarmdigital.display.carousel
{
	import flash.display.InteractiveObject;
	
	/**
	 * For items to be included in the Carousel display, they must implement this interface.
	 */
	public interface ICarouselItem
	{
		/**
		 * This should return the DisplayObject to use as a display for this item.
		 */
		function get display():InteractiveObject;
		/**
		 * This should return the virtual angle at which the item should sit within the Carousel.
		 * If NaN is returned then an angle will be calculated for the item
		 */
		function get angleOffset():Number;
	}
}