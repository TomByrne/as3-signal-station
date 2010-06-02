package org.farmcode.sodalityLibrary.data
{
	import org.farmcode.sodality.advice.IAdvice;
	
	public interface IDataProviderAdvice extends IAdvice
	{
		function get success(): Boolean;
		function get result(): *;
	}
}