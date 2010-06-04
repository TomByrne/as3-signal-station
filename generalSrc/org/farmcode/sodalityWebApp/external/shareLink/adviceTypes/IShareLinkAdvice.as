package org.farmcode.sodalityWebApp.external.shareLink.adviceTypes
{
	import org.farmcode.sodality.advice.IAdvice;
	
	public interface IShareLinkAdvice extends IAdvice
	{
		function get shareLinkTitle():String;
		function get shareLinkUrl():String;
		function get shareLinkType():String;
	}
}