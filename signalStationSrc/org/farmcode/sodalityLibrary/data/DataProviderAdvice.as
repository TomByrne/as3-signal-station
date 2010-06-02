package org.farmcode.sodalityLibrary.data
{
	import org.farmcode.sodality.advice.Advice;
	
	public class DataProviderAdvice extends Advice implements IDataProviderAdvice
	{
		protected var _result: *;
		protected var _success: *;
		
		public function DataProviderAdvice(abortable:Boolean=true)
		{
			super(abortable);
		}
		
		public function set result(result: *): void
		{
			this._result = result;
		}
		public function get result(): *
		{
			return this._result;
		}
		
		public function set success(success: Boolean): void
		{
			this._success = success;
		}
		public function get success(): Boolean
		{
			return this._success;
		}
	}
}