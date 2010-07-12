package org.farmcode.actLibrary.errors.acts
{
	import org.farmcode.actLibrary.errors.actTypes.IErrorAct;
	import org.farmcode.acting.acts.UniversalAct;

	public class ErrorAct extends UniversalAct implements IErrorAct
	{
		public function get errorType():String{
			return _errorType;
		}
		public function set errorType(value:String):void{
			_errorType = value;
		}
		
		private var _errorType:String;
		private var _errorTarget: Object;
		
		public function ErrorAct(errorType:String=null, errorTarget: Object = null){
			super();
			this.errorType = errorType;
			this.errorTarget = errorTarget;
		}
		
		public function get errorTarget(): Object{
			return this._errorTarget;
		}
		public function set errorTarget(value: Object): void{
			this._errorTarget = value;
		}
	}
}