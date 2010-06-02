package org.farmcode.sodalityLibrary.external.browser.advice
{
	import org.farmcode.sodalityLibrary.external.browser.adviceTypes.INavigateToURLAdvice;
	
	import org.farmcode.sodality.advice.Advice;

	public class NavigateToURLAdvice extends Advice implements INavigateToURLAdvice
	{
		[Property(toString="true",clonable="true")]
		public function get linkUrl():String{
			return _linkUrl;
		}
		public function set linkUrl(value:String):void{
			if(_linkUrl!=value){
				_linkUrl = value;
			}
		}
		
		[Property(toString="true",clonable="true")]
		public function get targetWindow():String{
			return _targetWindow;
		}
		public function set targetWindow(value:String):void{
			if(_targetWindow!=value){
				_targetWindow = value;
			}
		}
		
		private var _targetWindow:String;
		private var _linkUrl:String;
		
		public function NavigateToURLAdvice(url:String=null, targetWindow:String=null){
			this.linkUrl = url;
			this.targetWindow = targetWindow;
		}
	}
}