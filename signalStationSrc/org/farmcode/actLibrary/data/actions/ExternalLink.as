package org.farmcode.actLibrary.data.actions
{
	import org.farmcode.actLibrary.external.browser.acts.NavigateToURLAct;
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.data.actions.AbstractLink;

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
		
		private var _triggerAction:NavigateToURLAct = new NavigateToURLAct();
		
		public function ExternalLink() {
			super();
		}
		override protected function getAct():IAct{
			return _triggerAction;
		}
	}
}