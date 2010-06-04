package org.farmcode.sodalityWebApp.external.shareLink
{
	import org.farmcode.sodality.advisors.DynamicAdvisor;
	import org.farmcode.sodalityLibrary.external.browser.advice.OpenBrowserWindowAdvice;
	import org.farmcode.sodalityWebApp.external.shareLink.adviceTypes.IShareLinkAdvice;
	
	public class ShareLinkAdvisor extends DynamicAdvisor
	{
		private static const BASE_URL:String = "http://addthis.com/bookmark.php?";
		private static const URL_VAR:String = "url";
		private static const TITLE_VAR:String = "title";
		private static const TYPE_VAR:String = "s";
		
		public function ShareLinkAdvisor(){
			super();
		}
		[Trigger(type="org.farmcode.sodalityLibrary.triggers.ImmediateAfterTrigger")]
		public function afterShareLink(cause:IShareLinkAdvice): void{
			if(cause.shareLinkUrl && cause.shareLinkUrl.length){
				var url:String = BASE_URL;
				url = addVariable(url,cause.shareLinkUrl,URL_VAR);
				url = addVariable(url,cause.shareLinkTitle,TITLE_VAR);
				url = addVariable(url,cause.shareLinkType,TYPE_VAR);
				
				var openWindow:OpenBrowserWindowAdvice = new OpenBrowserWindowAdvice();
				openWindow.windowURL = url;
				openWindow.windowHeight = 500;
				openWindow.windowWidth = 500;
				openWindow.displayChrome = false;
				dispatchEvent(openWindow);
			}
		}
		protected function addVariable(url:String, value:String, name:String):String{
			if(value && value.length){
				return url+name+"="+escape(value)+"&";
			}else{
				return url;
			}
		}
	}
}