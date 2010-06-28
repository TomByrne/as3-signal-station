package org.farmcode.acting.bubbling
{
	import org.farmcode.acting.actTypes.IAct;

	public interface IBubbleHub
	{
		/**
		 * This act should be handled by the parent IBubbleHub, not directly referenced
		 * by listening code.
		 * 
		 * handler(bubblableAct:IBubblableAct, params:Array)
		 */
		function get onBubbled():IAct;
		
		function addHandler(bubbleId:String, handler:Function, additionalParameters:Array):void;
		function removeHandler(bubbleId:String, handler:Function):void;
	}
}