package org.farmcode.sodalityWebApp.external.shareLink.advice
{
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodalityLibrary.external.browser.adviceTypes.IGetCurrentURLAdvice;
	import org.farmcode.sodalityLibrary.external.swfaddress.adviceTypes.IGetPageTitleAdvice;
	import org.farmcode.sodalityWebApp.external.shareLink.adviceTypes.IShareLinkAdvice;
	
	public class ShareCurrentLinkAdvice extends Advice implements IShareLinkAdvice, IGetPageTitleAdvice, IGetCurrentURLAdvice
	{
		
		[Property(toString="true",clonable="true")]
		public function get shareLinkType():String{
			return _shareLinkType;
		}
		public function set shareLinkType(value:String):void{
			_shareLinkType = value;
		}
		public function set pageTitle(value:String):void{
			_pageTitle = value;
		}
		public function get shareLinkTitle():String{
			return _pageTitle;
		}
		public function set currentURL(value:String):void{
			_currentURL = value;
		}
		public function get shareLinkUrl():String{
			return _currentURL;
		}
		
		private var _currentURL:String;
		private var _pageTitle:String;
		private var _shareLinkType:String;
		
		public function ShareCurrentLinkAdvice(shareLinkType:String=null){
			this.shareLinkType = shareLinkType;
		}
	}
}