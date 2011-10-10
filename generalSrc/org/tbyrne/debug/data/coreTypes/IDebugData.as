package org.tbyrne.debug.data.coreTypes
{
	import org.tbyrne.data.controls.IControlData;
	import org.tbyrne.data.dataTypes.IBitmapDataProvider;
	import org.tbyrne.display.core.ILayoutView;

	public interface IDebugData extends IControlData
	{
		function get bitmapDataValue():IBitmapDataProvider;
		function get layoutView():ILayoutView;
	}
}