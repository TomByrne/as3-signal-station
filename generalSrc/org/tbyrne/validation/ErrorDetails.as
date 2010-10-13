package org.tbyrne.validation
{
	// TODO: recomcile this with the other ErrorDetails class
	public class ErrorDetails implements IErrorDetails
	{
		public function get message():String{
			return _message;
		}
		public function set message(value:String):void{
			_message = value;
		}
		
		private var _message:String;
		
		public function ErrorDetails(message:String=null){
			this.message = message;
		}
	}
}