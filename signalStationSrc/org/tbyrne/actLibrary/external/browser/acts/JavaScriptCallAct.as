package org.tbyrne.actLibrary.external.browser.acts
{
	import org.tbyrne.actLibrary.external.browser.actTypes.IJavaScriptCallAct;
	import org.tbyrne.acting.acts.UniversalAct;

	public class JavaScriptCallAct extends UniversalAct implements IJavaScriptCallAct
	{
		[Property(toString="true",clonable="true")]
		public function get methodName():String{
			return _methodName;
		}
		public function set methodName(value:String):void{
			if(_methodName!=value){
				_methodName = value;
			}
		}
		
		
		[Property(toString="true",clonable="true")]
		public function get parameters():Array{
			return _parameters;
		}
		public function set parameters(value:Array):void{
			if(_parameters!=value){
				_parameters = value;
			}
		}
		
		[Property(toString="true",clonable="true")]
		public function get javascriptResult():*{
			return _javascriptResult;
		}
		public function set javascriptResult(value:*):void{
			_javascriptResult = value;
		}
		
		private var _javascriptResult:*;
		private var _methodName:String;
		private var _parameters:Array;
		
		public function JavaScriptCallAct(methodName:String=null, ... parameters){
			this.methodName = methodName;
			this.parameters = parameters;
		}
	}
}