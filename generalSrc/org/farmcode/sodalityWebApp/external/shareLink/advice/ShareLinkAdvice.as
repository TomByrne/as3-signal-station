package org.farmcode.sodalityWebApp.external.shareLink.advice
{
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodalityWebApp.external.shareLink.adviceTypes.IShareLinkAdvice;
	
	public class ShareLinkAdvice extends Advice implements IShareLinkAdvice
	{
		
		[Property(toString="true",clonable="true")]
		public function get shareLinkTitle():String{
			return _shareLinkTitle;
		}
		public function set shareLinkTitle(value:String):void{
			_shareLinkTitle = value;
		}
		
		[Property(toString="true",clonable="true")]
		public function get shareLinkUrl():String{
			return _shareLinkUrl;
		}
		public function set shareLinkUrl(value:String):void{
			_shareLinkUrl = value;
		}
		
		[Property(toString="true",clonable="true")]
		public function get shareLinkType():String{
			return _shareLinkType;
		}
		public function set shareLinkType(value:String):void{
			_shareLinkType = value;
		}
		
		private var _shareLinkType:String;
		private var _shareLinkUrl:String;
		private var _shareLinkTitle:String;
		
		public function ShareLinkAdvice(shareLinkUrl:String=null,shareLinkTitle:String=null,shareLinkType:String=null){
			super();
			this.shareLinkType = shareLinkType;
			this.shareLinkUrl = shareLinkUrl;
			this.shareLinkTitle = shareLinkTitle;
		}
	}
}