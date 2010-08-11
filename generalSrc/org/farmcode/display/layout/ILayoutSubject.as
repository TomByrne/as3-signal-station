package org.farmcode.display.layout
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.display.layout.core.ILayoutInfo;
	
	public interface ILayoutSubject
	{
		function get layoutInfo():ILayoutInfo;
		
		/**
		 * handler(from:ILayoutSubject, oldWidth:Number, oldHeight:Number)
		 */
		function get measurementsChanged():IAct;
		function get measurements():Point;
		
		// TODO: split position/size
		function get displayPosition():Rectangle;
		// TODO: split into  setSize and setPosition
		function setDisplayPosition(x:Number, y:Number, width:Number, height:Number):void;
		// TODO: split into positionChanged/sizeChanged
		/**
		 * handler(from:ILayoutSubject, oldX:Number, oldY:Number, oldWidth:Number, oldHeight:Number)
		 */
		function get positionChanged():IAct;
	}
}