package org.tbyrne.actLibrary.external.swfAddress.acts
{
	import org.tbyrne.actLibrary.external.swfAddress.actTypes.ISetSWFAddressAct;
	
	
	public class SetSWFAddressAct extends GetSWFAddressAct implements ISetSWFAddressAct
	{
		public function get onlyIfNotSet():Boolean{
			return _onlyIfNotSet;
		}
		public function set onlyIfNotSet(value:Boolean):void{
			_onlyIfNotSet = value;
		}
		
		private var _name:String;
		
		private var _onlyIfNotSet:Boolean;
		
		public function SetSWFAddressAct(swfAddress:String=null, onlyIfNotSet:Boolean=false){
			super();
			this.swfAddress = swfAddress;
			this.onlyIfNotSet = onlyIfNotSet;
		}
	}
}