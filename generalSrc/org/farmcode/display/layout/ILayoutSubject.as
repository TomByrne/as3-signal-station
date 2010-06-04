package org.farmcode.display.layout
{
	import flash.geom.Rectangle;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.display.layout.core.ILayoutInfo;

	public interface ILayoutSubject
	{
		function get displayMeasurements():Rectangle;
		function get layoutInfo():ILayoutInfo;
		function setDisplayPosition(x:Number, y:Number, width:Number, height:Number):void;
		
		
		/**
		 * handler(from:ILayoutSubject, oldX:Number, oldY:Number, oldWidth:Number, oldHeight:Number)
		 */
		function get measurementsChanged():IAct;
	}
}