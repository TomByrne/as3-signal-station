package au.com.thefarmdigital.validation
{
	public class ValidatorError
	{
		public var errorType:String;
		public var readableMessage:String;
		
		public function ValidatorError(errorType:String, readableMessage:String=null){
			this.errorType = errorType;
			this.readableMessage = readableMessage;
			this.readableMessage = readableMessage;
		}

	}
}