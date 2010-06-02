package org.farmcode.sodalityLibrary.external.swfaddress.advice
{
	import org.farmcode.sodalityLibrary.external.swfaddress.adviceTypes.ISetSWFAddressAdvice;
	
	public class SetSWFAddressAdvice extends GetSWFAddressAdvice implements ISetSWFAddressAdvice
	{
		[Property(toString="true",clonable="true")]
		public function get onlyIfNotSet():Boolean{
			return _onlyIfNotSet;
		}
		public function set onlyIfNotSet(value:Boolean):void{
			_onlyIfNotSet = value;
		}
		
		private var _name:String;
		
		private var _onlyIfNotSet:Boolean;
		
		public function SetSWFAddressAdvice(swfAddress:String=null, onlyIfNotSet:Boolean=false){
			super();
			this.swfAddress = swfAddress;
			this.onlyIfNotSet = onlyIfNotSet;
		}
	}
}