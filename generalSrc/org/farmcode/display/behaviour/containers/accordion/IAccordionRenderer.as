package org.farmcode.display.behaviour.containers.accordion
{
	import flash.geom.Rectangle;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.data.dataTypes.IStringProvider;
	import org.farmcode.display.behaviour.ILayoutViewBehaviour;
	
	/**
	 * TODO: refactor this to use ISelectableRenderer
	 */
	public interface IAccordionRenderer extends ILayoutViewBehaviour
	{
		function get minimumSize():Rectangle;
		function get maximumSize():Rectangle;
		
		function set open(value:Boolean):void;
		function set data(value:IStringProvider):void;
		function set accordionIndex(value:int):void;
		
		function setOpenSize(x:Number, y:Number, width:Number, height:Number):void;
		
		
		/**
		 * handler(from:IAccordionRenderer)
		 */
		function get select():IAct;
	}
}