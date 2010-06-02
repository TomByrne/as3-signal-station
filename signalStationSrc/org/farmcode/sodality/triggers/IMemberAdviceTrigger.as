package org.farmcode.sodality.triggers
{
	import org.farmcode.sodality.advice.IAdvice;
	
	public interface IMemberAdviceTrigger extends IAdviceTrigger
	{
		function get advice():Array;
		function set advice(value:Array):void;
	}
}