package org.farmcode.actLibrary.external.browser
{
	import flash.net.navigateToURL;
	
	import org.farmcode.actLibrary.core.UniversalActorHelper;
	import org.farmcode.actLibrary.external.browser.actTypes.INavigateToURLAct;
	import org.farmcode.acting.ActingNamspace;
	import org.farmcode.acting.universal.UniversalActExecution;
	
	use namespace ActingNamspace;
	
	public class BrowserActor extends UniversalActorHelper
	{
		public function BrowserActor(){
			metadataTarget = this;
		}
		
		public var navigatePhases:Array = [BrowserPhases.NAVIGATE_TO_URL];
		[ActRule(ActClassRule)]
		[ActReaction(phases="{navigatePhases}")]
		public function onNavigateToURL(cause:INavigateToURLAct):void{
			navigateToURL(new URLRequest(cause.linkUrl), cause.targetWindow);
		}
	}
}