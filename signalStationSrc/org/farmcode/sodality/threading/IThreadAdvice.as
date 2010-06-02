package org.farmcode.sodality.threading
{
	import org.farmcode.sodality.advice.IAdvice;
	
	public interface IThreadAdvice extends IAdvice
	{
		function get threadId():String;
	}
}