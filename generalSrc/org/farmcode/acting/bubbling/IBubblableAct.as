package org.farmcode.acting.bubbling
{
	import org.farmcode.acting.actTypes.IAct;
	
	public interface IBubblableAct extends IAct
	{
		function get bubbleId():String;
		function get shouldBubble():Boolean;
	}
}