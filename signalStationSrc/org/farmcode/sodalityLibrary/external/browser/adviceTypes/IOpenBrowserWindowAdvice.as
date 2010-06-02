package org.farmcode.sodalityLibrary.external.browser.adviceTypes
{
	import org.farmcode.sodality.advice.IAdvice;
	
	public interface IOpenBrowserWindowAdvice extends IAdvice
	{
		function get windowURL():String;
		function get windowName():String;
		
		function get windowWidth():Number;
		function get windowHeight():Number;
		function get windowX():Number;
		function get windowY():Number;
		
		function get copyHistory():Boolean;
		
		function get windowIsResizable():Boolean;
		
		function get displayLocationBar():Boolean;
		function get displayMenuBar():Boolean;
		function get displayStaturBar():Boolean;
		function get displayToolBar():Boolean;
		function get displayScrollBars():Boolean;
	}
}