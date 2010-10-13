package org.tbyrne.display.assets.schemaTypes
{
	public interface IRectangleAssetSchema extends IDisplayAssetSchema, IContainerAssetSchema
	{
		function get width():Number;
		function get height():Number;
		/**
		 * hitAreas and the like will return this as false
		 */
		function get visible():Boolean;
	}
}