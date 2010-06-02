package org.farmcode.sodalityLibrary.errors.adviceTypes
{
	import org.farmcode.sodalityLibrary.errors.ErrorDetails;
	
	public interface IDetailedErrorAdvice extends IErrorAdvice
	{
		function get errorDetails():ErrorDetails;
	}
}