package org.farmcode.display.layout
{
	import flash.geom.Rectangle;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.display.layout.core.ILayoutInfo;
	
	public interface ILayoutSubject
	{
		// TODO: turn displayMeasurements into Point object (and maybe rename measurements)
		function get displayMeasurements():Rectangle;
		function get layoutInfo():ILayoutInfo;
		
		// TODO: rename position/bounds
		function get displayPosition():Rectangle;
		// TODO: rename setPositionAndSize/setBounds (maybe introduce setSize and setPosition)
		function setDisplayPosition(x:Number, y:Number, width:Number, height:Number):void;
		
		
		/**
		 * handler(from:ILayoutSubject, oldX:Number, oldY:Number, oldWidth:Number, oldHeight:Number)
		 */
		function get measurementsChanged():IAct;
		
		// TODO: maybe rename boundsChanged
		/**
		 * handler(from:ILayoutSubject, oldX:Number, oldY:Number, oldWidth:Number, oldHeight:Number)
		 */
		function get positionChanged():IAct;
	}
}