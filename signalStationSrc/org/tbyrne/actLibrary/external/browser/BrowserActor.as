package org.tbyrne.actLibrary.external.browser
{
	import flash.external.ExternalInterface;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.Dictionary;
	
	import org.tbyrne.actLibrary.core.UniversalActorHelper;
	import org.tbyrne.actLibrary.external.browser.actTypes.*;
	import org.tbyrne.actLibrary.external.browser.acts.JavaScriptCallAct;
	import org.tbyrne.acting.ActingNamspace;
	import org.tbyrne.acting.universal.UniversalActExecution;
	
	use namespace ActingNamspace;
	
	public class BrowserActor extends UniversalActorHelper
	{
		private var _addedHandlers:Dictionary;
		private var _openWindowAct:JavaScriptCallAct;
		
		
		public function BrowserActor(){
			metadataTarget = this;
			_openWindowAct = new JavaScriptCallAct("window.open")
		}
		
		public var navigatePhases:Array = [BrowserPhases.NAVIGATE_TO_URL];
		[ActRule(ActClassRule)]
		[ActReaction(phases="<navigatePhases>")]
		public function onNavigateToURL(cause:INavigateToURLAct):void{
			navigateToURL(new URLRequest(cause.linkUrl), cause.targetWindow);
		}
		[ActRule(ActClassRule)]
		[ActReaction(phases="<navigatePhases>")]
		public function onOpenBrowserWindow(execution:UniversalActExecution, cause:IOpenBrowserWindowAct):void{
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
			
			_openWindowAct.parameters = [cause.windowURL,cause.windowName,optionsStr];
			_openWindowAct.perform(execution);
		}
		private function optionBoolean(value:Boolean):String{
			return value?"":"=No";
		}
		public var addCallbackPhases:Array = [BrowserPhases.ADD_CALLBACK];
		[ActRule(ActClassRule)]
		[ActReaction(phases="<addCallbackPhases>")]
		public function onAddCallback(cause:IAddExternalCallbackHandlerAct):void{
			if(!_addedHandlers)_addedHandlers = new Dictionary();
			if(ExternalInterface.available && (!cause.onlyAddIfNotAlready || !_addedHandlers[cause.callbackName])){
				ExternalInterface.addCallback(cause.callbackName, cause.callbackHandler);
				_addedHandlers[cause.callbackName] = true;
				cause.addedSuccessfully = true;
			}else{
				cause.addedSuccessfully = false;
			}
		}
		
		public var javascriptCallPhases:Array = [BrowserPhases.JAVASCRIPT_CALL];
		[ActRule(ActClassRule)]
		[ActReaction(phases="<javascriptCallPhases>")]
		public function onJavaScriptCall(cause:IJavaScriptCallAct):void{
			if(ExternalInterface.available){
				var args:Array = [cause.methodName].concat(cause.parameters);
				cause.javascriptResult = ExternalInterface.call.apply(null,args);
			}else{
				var params:String = cause.parameters.join("','");
				var script:String = "javascript:"+cause.methodName+"('"+params+"');";
				navigateToURL(new URLRequest(script));
			}
		}
		public var getCurrentURLPhases:Array = [BrowserPhases.GET_CURRENT_URL];
		[ActRule(ActClassRule)]
		[ActReaction(phases="<getCurrentURLPhases>")]
		public function onGetCurrentURL(cause:IGetCurrentURLAct):void{
			if(ExternalInterface.available){
				cause.currentURL = ExternalInterface.call("function(){return document.location.href}");
			}else{
				Log.error( "BrowserAdvisor.onGetCurrentURL: IGetCurrentURLAdvice cannot be executed without ExternalInterface being available");
			}
		}
	}
}