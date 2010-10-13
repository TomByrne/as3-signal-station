package org.tbyrne.display.assets.stylable.styles
{
	import flash.display.Shape;
	
	import org.tbyrne.display.assets.schemaTypes.IAssetSchema;

	public interface IRectangleStyle extends IStyle
	{
		/**
		 * @param oldStyles the list of styles that was applied last time this was drawn
		 * @return amount of time (in seconds) required to apply the style.
		 */
		function styleRectangle(shape:Shape, width:Number, height:Number, oldStyles:Array):Number;
		function refreshRectangleStyle(shape:Shape, width:Number, height:Number, oldStyles:Array):Number;
		function unstyleRectangle(shape:Shape):Number;
	}
}