package org.tbyrne.acting.bubbling
{
	import org.tbyrne.acting.actTypes.IAct;
	
	public interface IBubblableAct extends IAct
	{
		function get bubbleId():String;
		function get shouldBubble():Boolean;
	}
}