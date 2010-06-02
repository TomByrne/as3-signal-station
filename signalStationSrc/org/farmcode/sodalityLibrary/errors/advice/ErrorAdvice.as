package org.farmcode.sodalityLibrary.errors.advice
{
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodalityLibrary.errors.adviceTypes.IErrorAdvice;

	public class ErrorAdvice extends Advice implements IErrorAdvice
	{
		[Property(toString="true",clonable="true")]
		public function get errorType():String{
			return _errorType;
		}
		public function set errorType(value:String):void{
			//if(_errorType != value){
				_errorType = value;
			//}
		}
		
		private var _errorType:String;
		private var _errorTarget: Object;
		
		// TODO: Throw error or error event if nothing caught this advice
		public function ErrorAdvice(errorType:String=null, errorTarget: Object = null){
			super(abortable);
			this.errorType = errorType;
			this.errorTarget = errorTarget;
		}
		
		[Property(toString="true", clonable="true")]
		public function get errorTarget(): Object
		{
			return this._errorTarget;
		}
		public function set errorTarget(value: Object): void
		{
			this._errorTarget = value;
		}
	}
}