package org.tbyrne.umbraco
{
	/** Converts Umbraco TinyMCE Rich Editor content block to TextField htmlText ready string.
	 *  Formatting isn't applied to <b> or <strong> so all Umbraco references are converted 
	 *  to <span class='bold'> and used in conjunction to UmbracoStyleLoader.
	 */
	
	public class UmbracoStringParser
	{
		public static function parseHTML(htmlText:String):String {
			
			htmlText = htmlText.replace(/<strong>/gi, "<b>");
			htmlText = htmlText.replace(/<\/strong>/gi, "</b>");
			htmlText = htmlText.replace(/<br\s?\/>/gi, "<br>");
			
			// To patch issue with Umbraco TinyMCE returning linebreaks after text in editor			
			htmlText = htmlText.replace(/[\n\r]/g, " ");
			htmlText = htmlText.replace(/<br>\s*/gi, "<br>");
			htmlText = htmlText.replace(/<\/p>\s*/gi, "</p>");
			htmlText = htmlText.replace(/\s*<p>/gi, "<p>");
			
			return htmlText;
		}
	}
}