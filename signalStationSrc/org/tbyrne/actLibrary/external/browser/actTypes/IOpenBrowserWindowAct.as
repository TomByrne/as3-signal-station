package org.tbyrne.actLibrary.external.browser.actTypes
{
	import org.tbyrne.acting.actTypes.IUniversalAct;
	
	public interface IOpenBrowserWindowAct extends IUniversalAct
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