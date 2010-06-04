package org.farmcode.sodalityWebApp.data.navigation
{
	import org.farmcode.data.dataTypes.IStringProvider;
	import org.farmcode.data.dataTypes.ITriggerableAction;
	import org.farmcode.sodality.advice.IAdvice;
	import org.farmcode.sodalityLibrary.external.browser.advice.NavigateToURLAdvice;

	public class ExternalLink extends AbstractLink
	{
		public function get linkUrl():String{
			return _triggerAction.linkUrl;
		}
		public function set linkUrl(value:String):void{
			_triggerAction.linkUrl = value;
		}
		public function get targetWindow():String{
			return _triggerAction.targetWindow;
		}
		public function set targetWindow(value:String):void{
			_triggerAction.targetWindow = value;
		}
		
		override public function triggerAction():IAdvice{
			return _triggerAction;
		}		
		
		private var _triggerAction:NavigateToURLAdvice = new NavigateToURLAdvice();
		
		public function ExternalLink() {
			super();
		}
	}
}