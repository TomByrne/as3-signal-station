package org.farmcode.sodalityLibrary.data
{
	import org.farmcode.sodalityLibrary.core.advice.CascadingAdvice;

	public class DataDependantAdvice extends CascadingAdvice implements IDataDependantAdvice
	{
		[Property(toString="true",clonable="true")]
		public var result: *;
		
		public function DataDependantAdvice(abortable:Boolean=true)
		{
			super(abortable);
			this.linkedRequired = true;
		}
		
		public function set dataProviderAdvice(dataProviderAdvice: IDataProviderAdvice): void
		{
			var advice: Array = [];
			if (dataProviderAdvice != null)
			{
				advice.push(dataProviderAdvice);
			}
			super.linkedAdvice = advice;
		}
		public function get dataProviderAdvice(): IDataProviderAdvice
		{
			return super.linkedAdvice[0] as IDataProviderAdvice;
		}
		
		[Property(toString="true",clonable="true")]
		override public function set linkedAdvice(linkedAdvice: Array):void
		{
			this.dataProviderAdvice = linkedAdvice[0] as IDataProviderAdvice;
		}
		override public function get linkedAdvice():Array
		{
			var advice: Array = new Array();
			if (this.dataProviderAdvice)
			{
				advice.unshift(this.dataProviderAdvice);
			}
			return advice;
		}
		
		override protected function linkedAdviceComplete(): void
		{
			this.result = this.dataProviderAdvice.result;
			super.linkedAdviceComplete();
		}
	}
}