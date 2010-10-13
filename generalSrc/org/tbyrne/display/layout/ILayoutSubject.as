package org.tbyrne.display.layout
{
	import flash.geom.Point;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.display.layout.core.ILayoutInfo;
	
	public interface ILayoutSubject
	{
		function get layoutInfo():ILayoutInfo;
		
		/**
		 * handler(from:ILayoutSubject, oldWidth:Number, oldHeight:Number)
		 */
		function get measurementsChanged():IAct;
		function get measurements():Point;
		
		
		
		function get position():Point;
		function setPosition(x:Number, y:Number):void;
		/**
		 * handler(from:ILayoutSubject, oldWidth:Number, oldHeight:Number)
		 */
		function get positionChanged():IAct;
		
		
		
		function get size():Point;
		function setSize(width:Number, height:Number):void;
		/**
		 * handler(from:ILayoutSubject, oldWidth:Number, oldHeight:Number)
		 */
		function get sizeChanged():IAct;
	}
}