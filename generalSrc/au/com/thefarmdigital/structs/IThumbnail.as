package au.com.thefarmdigital.structs
{
	/**
	 * An item that has a thumbnail representation
	 */
	public interface IThumbnail
	{
		/** The url to the thumbnail representation of this object */
		function get thumbnailURL():String;
	}
}