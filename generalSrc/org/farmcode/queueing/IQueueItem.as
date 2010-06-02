package org.farmcode.queueing
{
	import org.farmcode.acting.actTypes.IAct;
	
	public interface IQueueItem
	{
		function get totalSteps():uint;
		function step(currentStep:uint):void;
		function get stepFinished():IAct;// (queueItem:IQueueItem)
	}
}