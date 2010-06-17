package org.farmcode.actLibrary.errors.acts
{
	import org.farmcode.actLibrary.errors.ErrorDetails;
	import org.farmcode.actLibrary.errors.actTypes.IDetailedErrorAct;
	
	public class DetailedErrorAct extends ErrorAct implements IDetailedErrorAct
	{
		public function get errorDetails():org.farmcode.actLibrary.errors.ErrorDetails{
			return _errorDetails;
		}
		public function set errorDetails(value:ErrorDetails):void{
			_errorDetails = value;
		}
		
		private var _errorDetails:ErrorDetails;
		
		public function DetailedErrorAct(errorType:String=null, errorDetails:ErrorDetails=null, target: Object = null){
			super(errorType, target);
			this.errorDetails = errorDetails;
		}
		
	}
}