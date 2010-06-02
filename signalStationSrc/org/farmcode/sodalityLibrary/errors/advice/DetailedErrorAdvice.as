package org.farmcode.sodalityLibrary.errors.advice
{
	import org.farmcode.sodalityLibrary.errors.ErrorDetails;
	import org.farmcode.sodalityLibrary.errors.adviceTypes.IDetailedErrorAdvice;
	
	public class DetailedErrorAdvice extends ErrorAdvice implements IDetailedErrorAdvice
	{
		[Property(toString="true",clonable="true")]
		public function get errorDetails():ErrorDetails{
			return _errorDetails;
		}
		public function set errorDetails(value:ErrorDetails):void{
			//if(_errorDetails != value){
				_errorDetails = value;
			//}
		}
		
		private var _errorDetails:ErrorDetails;
		
		public function DetailedErrorAdvice(errorType:String=null, errorDetails:ErrorDetails=null,
			target: Object = null)
		{
			super(errorType, target);
			this.errorDetails = errorDetails;
		}
		
	}
}