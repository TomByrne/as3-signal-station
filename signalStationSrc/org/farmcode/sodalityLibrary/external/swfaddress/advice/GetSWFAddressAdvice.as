package org.farmcode.sodalityLibrary.external.swfaddress.advice
{
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodalityLibrary.external.swfaddress.adviceTypes.IGetPageTitleAdvice;
	import org.farmcode.sodalityLibrary.external.swfaddress.adviceTypes.IGetSWFAddressAdvice;
	
	public class GetSWFAddressAdvice extends Advice implements IGetSWFAddressAdvice, IGetPageTitleAdvice
	{
		
		[Property(toString="true",clonable="true")]
		public function get swfAddress():String{
			return _swfAddress;
		}
		public function set swfAddress(value:String):void{
			_swfAddress = value;
		}
		
		[Property(toString="true",clonable="true")]
		public function get pageTitle():String{
			return _pageTitle;
		}
		public function set pageTitle(value:String):void{
			_pageTitle = value;
		}
		
		private var _pageTitle:String;
		private var _swfAddress:String;
		
		public function GetSWFAddressAdvice(abortable:Boolean=true){
			super(abortable);
		}
	}
}