package org.tbyrne.display.assets.schemaTypes
{
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;

	/**
	 * This is for non-input text
	 */
	public interface ITextAssetSchema extends IDisplayAssetSchema
	{
		function get initialText():String;
		function get width():Number;
		function get height():Number;
	}
}