package org.tbyrne.display.assets.schemaTypes
{
	public interface IAssetSchema
	{
		function get assetName():String;
		function get fallbackToGroup():Boolean;
		function get assetPath():String;
	}
}