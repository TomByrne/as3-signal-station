package org.tbyrne.actLibrary.external.browser.acts
{
	import org.tbyrne.actLibrary.external.browser.actTypes.IAddExternalCallbackHandlerAct;
	import org.tbyrne.acting.acts.UniversalAct;
	
	public class AddExternalCallbackHandlerAct extends UniversalAct implements IAddExternalCallbackHandlerAct
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
		
		public function AddExternalCallbackHandlerAct(callbackName:String=null,callbackHandler:Function=null,onlyAddIfNotAlready:Boolean=false){
			super();
			this.callbackName = callbackName;
			this.callbackHandler = callbackHandler;
			this.onlyAddIfNotAlready = onlyAddIfNotAlready;
		}
	}
}