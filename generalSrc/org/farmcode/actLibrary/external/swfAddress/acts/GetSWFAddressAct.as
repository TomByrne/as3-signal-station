package org.farmcode.actLibrary.external.swfAddress.acts
{
	import org.farmcode.actLibrary.external.swfAddress.actTypes.IGetSWFAddressAct;
	import org.farmcode.acting.acts.UniversalAct;
	
	public class GetSWFAddressAct extends UniversalAct implements IGetSWFAddressAct//, IGetPageTitleAct
	{
		
		public function get swfAddress():String{
			return _swfAddress;
		}
		public function set swfAddress(value:String):void{
			_swfAddress = value;
		}
		
		/*public function get pageTitle():String{
			return _pageTitle;
		}
		public function set pageTitle(value:String):void{
			_pageTitle = value;
		}
		
		private var _pageTitle:String;*/
		private var _swfAddress:String;
		
		public function GetSWFAddressAct(){
			super();
		}
	}
}