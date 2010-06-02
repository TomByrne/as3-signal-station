package org.farmcode.sodalityLibrary.external.remoting.errors
{
	import org.farmcode.sodalityLibrary.errors.ErrorDetails;
	import org.farmcode.sodalityLibrary.errors.advice.DetailedErrorAdvice;

	public class RemotingErrorAdvice extends DetailedErrorAdvice implements IRemotingErrorAdvice
	{
		private var _method: String;
		private var _parameters: Array;
		
		public function RemotingErrorAdvice(errorType:String=null, target: Object = null,
			errorDetails:ErrorDetails=null)
		{
			super(errorType, errorDetails, target);
		}
		
		[Property(toString="true", clonable="true")]
		public function get parameters(): Array
		{
			return this._parameters;
		}
		public function set parameters(value: Array): void
		{
			this._parameters = value;
		}

		[Property(toString="true", clonable="true")]
		public function get method(): String
		{
			return this._method;
		}
		public function set method(value: String): void
		{
			this._method = value;
		}
	}
}