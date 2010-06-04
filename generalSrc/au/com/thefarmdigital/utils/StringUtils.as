package au.com.thefarmdigital.utils
{
	/**
	 * A collection of utilities for operations on Strings
	 */
	public class StringUtils
	{
		/**
		 * Places characters in front of the given string until it is at least 
		 * defined length.
		 * 
		 * @param	source		The string to pad
		 * @param	destLength	The minimum length of the returned string
		 * @param	padChar		The character to place at the front of the source
		 *
		 * @return 	The padded string
		 */
		public static function pad(source: String, destLength: int, 
			padChar: String): String
		{
			var result: String = source;
			while (result.length < destLength)
			{
				result = padChar + result;
			}
			
			return result;
		}

	}
}