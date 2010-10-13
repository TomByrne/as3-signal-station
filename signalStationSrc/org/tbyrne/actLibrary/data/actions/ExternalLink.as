package org.tbyrne.actLibrary.data.actions
{
	import org.tbyrne.actLibrary.external.browser.acts.NavigateToURLAct;
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.data.actions.AbstractLink;

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