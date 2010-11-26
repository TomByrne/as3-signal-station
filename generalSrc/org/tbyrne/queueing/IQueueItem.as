package org.tbyrne.queueing
{
	import org.tbyrne.acting.actTypes.IAct;
	
	public interface IQueueItem
	{
		/**
		 * handler(queueItem:IQueueItem)
		 */
		function get stepFinished():IAct;
		function get totalSteps():uint;
		function step(currentStep:uint):void;
		
		
	}
}