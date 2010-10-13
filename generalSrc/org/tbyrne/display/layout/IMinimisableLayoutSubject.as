package org.tbyrne.display.layout
{
	import flash.geom.Point;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.data.dataTypes.IBooleanProvider;
	import org.tbyrne.display.core.ILayoutView;

	public interface IMinimisableLayoutSubject extends ILayoutSubject, IBooleanProvider
	{
		/**
		 * handler(from:IMinimisableView, oldX:Number, oldY:Number, oldWidth:Number, oldHeight:Number)
		 */
		function get minMeasurementsChanged():IAct;
		/**
		 * handler(from:IMinimisableView)
		 */
		function get openFractChanged():IAct;
		
		function get minMeasurements():Point;
		function get openFract():Number;
		function setOpenArea(width:Number, height:Number):void;
	}
}