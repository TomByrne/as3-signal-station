package org.farmcode.display.assets.schemaTypes
{
	import org.farmcode.display.assets.assetTypes.IDisplayAsset;

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