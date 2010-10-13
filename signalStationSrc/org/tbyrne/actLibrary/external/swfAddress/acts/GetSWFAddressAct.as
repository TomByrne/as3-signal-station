package org.tbyrne.actLibrary.external.swfAddress.acts
{
	import org.tbyrne.actLibrary.external.swfAddress.actTypes.IGetSWFAddressAct;
	import org.tbyrne.acting.acts.UniversalAct;
	
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