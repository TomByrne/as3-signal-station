package org.tbyrne.display.assets.stylable.styles
{
	import org.tbyrne.display.assets.schemaTypes.IAssetSchema;

	public interface IStyle
	{
		function get stateName():String;
		function matchesSchema(schema:IAssetSchema, otherStyles:Array):Boolean;
		function allowConcurrentWith(currStyles:Array):Boolean;
	}
}