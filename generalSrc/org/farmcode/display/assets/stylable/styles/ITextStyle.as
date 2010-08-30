package org.farmcode.display.assets.stylable.styles
{
	import flash.text.TextField;
	
	import org.farmcode.display.assets.schemaTypes.IAssetSchema;

	public interface ITextStyle extends IStyle
	{
		/**
		 * @param oldStyles the list of styles that was applied last time this was drawn
		 * @return amount of time (in seconds) required to apply the style.
		 */
		function styleText(textField:TextField, oldStyles:Array):Number;
		function refreshTextStyle(textField:TextField, oldStyles:Array):Number;
		function unstyleText(textField:TextField):Number;
	}
}