package org.farmcode.sodalityLibrary.external.browser
{
	import flash.external.ExternalInterface;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.Dictionary;
	
	import org.farmcode.sodality.advisors.DynamicAdvisor;
	import org.farmcode.sodalityLibrary.external.browser.advice.JavaScriptCallAdvice;
	import org.farmcode.sodalityLibrary.external.browser.adviceTypes.IAddExternalCallbackHandlerAdvice;
	import org.farmcode.sodalityLibrary.external.browser.adviceTypes.IGetCurrentURLAdvice;
	import org.farmcode.sodalityLibrary.external.browser.adviceTypes.IJavaScriptCallAdvice;
	import org.farmcode.sodalityLibrary.external.browser.adviceTypes.INavigateToURLAdvice;
	import org.farmcode.sodalityLibrary.external.browser.adviceTypes.IOpenBrowserWindowAdvice;
	
	public class BrowserAdvisor extends DynamicAdvisor
	{
		private var _addedHandlers:Dictionary;
		
		
		[Trigger(triggerTiming="before")]
		public function onNavigateToURL(cause:INavigateToURLAdvice): void{
			navigateToURL(new URLRequest(cause.linkUrl), cause.targetWindow);
		}
		
		[Trigger(triggerTiming="before")]
		public function onOpenBrowserWindow(cause:IOpenBrowserWindowAdvice): void{
			var optionsStr:String = "'";
			if(cause.windowWidth && !isNaN(cause.windowWidth))optionsStr += "width="+cause.windowWidth+",";
			if(cause.windowHeight && !isNaN(cause.windowHeight))optionsStr += "height="+cause.windowHeight+",";
			if(cause.windowX && !isNaN(cause.windowX))optionsStr += "left="+cause.windowX+",";
			if(cause.windowY && !isNaN(cause.windowY))optionsStr += "top="+cause.windowY+",";
			
			optionsStr += "copyhistory"+optionBoolean(cause.copyHistory)+",";
			optionsStr += "resizable"+optionBoolean(cause.windowIsResizable)+",";
			optionsStr += "location"+optionBoolean(cause.displayLocationBar)+",";
			optionsStr += "menubar"+optionBoolean(cause.displayMenuBar)+",";
			optionsStr += "status"+optionBoolean(cause.displayStaturBar)+",";
			optionsStr += "toolbar"+optionBoolean(cause.displayToolBar)+",";
			optionsStr += "scrollbars"+optionBoolean(cause.displayScrollBars);
			
			dispatchEvent(new JavaScriptCallAdvice("window.open",cause.windowURL,cause.windowName,optionsStr));
		}
		private function optionBoolean(value:Boolean):String{
			return value?"":"=No";
		}
		[Trigger(triggerTiming="before")]
		public function onAddCallback(cause:IAddExternalCallbackHandlerAdvice): void{
			if(!_addedHandlers)_addedHandlers = new Dictionary();
			if(ExternalInterface.available && (!cause.onlyAddIfNotAlready || !_addedHandlers[cause.callbackName])){
				ExternalInterface.addCallback(cause.callbackName, cause.callbackHandler);
				_addedHandlers[cause.callbackName] = true;
				cause.addedSuccessfully = true;
			}else{
				cause.addedSuccessfully = false;
			}
		}
		
		[Trigger(triggerTiming="before")]
		public function onJavaScriptCall(cause:IJavaScriptCallAdvice): void{
			if(ExternalInterface.available){
				var args:Array = [cause.methodName].concat(cause.parameters);
				cause.javascriptResult = ExternalInterface.call.apply(null,args);
			}else{
				var params:String = cause.parameters.join("','");
				var script:String = "javascript:"+cause.methodName+"('"+params+"');";
				navigateToURL(new URLRequest(script));
			}
		}
		[Trigger(triggerTiming="before")]
		public function onGetCurrentURL(cause:IGetCurrentURLAdvice): void{
			if(ExternalInterface.available){
				cause.currentURL = ExternalInterface.call("function(){return document.location.href}");
			}else{
				throw new Error("BrowserAdvisor.onGetCurrentURL: IGetCurrentURLAdvice cannot be executed without ExternalInterface being available.");
			}
		}
	}
}