package org.farmcode.sodalityPlatformEngine.core.adviceTypes
{
	import org.farmcode.sodality.advice.IAdvice;
	import org.farmcode.sodalityPlatformEngine.core.IApplicationData;
	
	public interface IApplicationInitAdvice extends IAdvice
	{
		function get applicationData():IApplicationData;
	}
}