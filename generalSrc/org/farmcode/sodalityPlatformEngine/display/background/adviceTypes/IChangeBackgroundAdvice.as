package org.farmcode.sodalityPlatformEngine.display.background.adviceTypes
{
	import org.farmcode.sodality.advice.IAdvice;
	
	import flash.display.DisplayObject;
	
	public interface IChangeBackgroundAdvice extends IAdvice
	{
		function get background():DisplayObject;
	}
}