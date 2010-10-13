package org.tbyrne.actLibrary.errors
{
	import flash.display.DisplayObject;
	
	public class ErrorDetails
	{
		public function ErrorDetails(message:String = "error", errorDisplay: IErrorDisplay = null){
			this.message = message;
			this.errorDisplay = errorDisplay;
		}
		
		public var message:String;
		public var errorDisplay:IErrorDisplay;
	}
}