package org.farmcode.sodalityLibrary.data
{
	import org.farmcode.sodality.advice.IAdvice;

	public interface IDataDependantAdvice extends IAdvice
	{
		function get dataProviderAdvice(): IDataProviderAdvice;
		function set dataProviderAdvice(value: IDataProviderAdvice): void;
	}
}