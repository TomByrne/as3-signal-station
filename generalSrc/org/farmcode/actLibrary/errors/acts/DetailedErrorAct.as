package org.farmcode.actLibrary.errors.acts
{
	import org.farmcode.actLibrary.errors.actTypes.IDetailedErrorAct;
	import org.farmcode.sodalityLibrary.errors.ErrorDetails;
	
	public class DetailedErrorAct extends ErrorAct implements IDetailedErrorAct
	{
		public function get errorDetails():ErrorDetails{
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