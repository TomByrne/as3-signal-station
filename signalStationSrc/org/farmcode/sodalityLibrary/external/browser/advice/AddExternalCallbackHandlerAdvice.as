package org.farmcode.sodalityLibrary.external.browser.advice
{
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodalityLibrary.external.browser.adviceTypes.IAddExternalCallbackHandlerAdvice;
	
	public class AddExternalCallbackHandlerAdvice extends Advice implements IAddExternalCallbackHandlerAdvice
	{
		
		[Property(toString="true",clonable="true")]
		public function get onlyAddIfNotAlready():Boolean{
			return _onlyAddIfNotAlready;
		}
		public function set onlyAddIfNotAlready(value:Boolean):void{
			_onlyAddIfNotAlready = value;
		}
		
		[Property(toString="true",clonable="true")]
		public function get callbackName():String{
			return _callbackName;
		}
		public function set callbackName(value:String):void{
			_callbackName = value;
		}
		
		[Property(toString="true",clonable="true")]
		public function get callbackHandler():Function{
			return _callbackHandler;
		}
		public function set callbackHandler(value:Function):void{
			_callbackHandler = value;
		}
		
		[Property(toString="true",clonable="true")]
		public function get addedSuccessfully():Boolean{
			return _addedSuccessfully;
		}
		public function set addedSuccessfully(value:Boolean):void{
			_addedSuccessfully = value;
		}
		
		private var _addedSuccessfully:Boolean;
		private var _callbackHandler:Function;
		private var _callbackName:String;
		private var _onlyAddIfNotAlready:Boolean;
		
		public function AddExternalCallbackHandlerAdvice(callbackName:String=null,callbackHandler:Function=null,onlyAddIfNotAlready:Boolean=false){
			super(abortable);
			this.callbackName = callbackName;
			this.callbackHandler = callbackHandler;
			this.onlyAddIfNotAlready = onlyAddIfNotAlready;
		}
	}
}