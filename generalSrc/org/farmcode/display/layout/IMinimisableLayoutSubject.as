package org.farmcode.display.layout
{
	import flash.geom.Point;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.data.dataTypes.IBooleanProvider;
	import org.farmcode.display.core.ILayoutView;

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