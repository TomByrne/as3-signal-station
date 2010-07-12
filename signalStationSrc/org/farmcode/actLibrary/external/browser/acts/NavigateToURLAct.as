package org.farmcode.actLibrary.external.browser.acts
{
	import org.farmcode.actLibrary.external.browser.actTypes.INavigateToURLAct;
	import org.farmcode.acting.acts.UniversalAct;
	
	public class NavigateToURLAct extends UniversalAct implements INavigateToURLAct
	{
		public function get linkUrl():String{
			return _linkUrl;
		}
		public function set linkUrl(value:String):void{
			_linkUrl = value;
		}
		public function get targetWindow():String{
			return _targetWindow;
		}
		public function set targetWindow(value:String):void{
			_targetWindow = value;
		}
		
		private var _targetWindow:String;
		private var _linkUrl:String;
		
		public function NavigateToURLAct(url:String=null, targetWindow:String=null){
			this.linkUrl = url;
			this.targetWindow = targetWindow;
		}
	}
}