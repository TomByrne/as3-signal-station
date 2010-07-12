package org.farmcode.actLibrary.external.swfAddress.acts
{
	import org.farmcode.actLibrary.external.swfAddress.actTypes.IGetSWFAddressAct;
	import org.farmcode.acting.acts.UniversalAct;
	
	public class GetSWFAddressAct extends UniversalAct implements IGetSWFAddressAct
	{
		public function get swfAddress():String{
			return _swfAddress;
		}
		public function set swfAddress(value:String):void{
			_swfAddress = value;
		}
		
		private var _swfAddress:String;
		
		public function GetSWFAddressAct(){
			super();
		}
	}
}