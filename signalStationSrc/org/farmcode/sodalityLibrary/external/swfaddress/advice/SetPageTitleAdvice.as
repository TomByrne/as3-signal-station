package org.farmcode.sodalityLibrary.external.swfaddress.advice
{
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodalityLibrary.external.swfaddress.adviceTypes.ISetPageTitleAdvice;
	
	public class SetPageTitleAdvice extends Advice implements ISetPageTitleAdvice
	{
		
		[Property(toString="true",clonable="true")]
		public function get pageTitle():String{
			return _pageTitle;
		}
		public function set pageTitle(value:String):void{
			_pageTitle = value;
		}
		
		private var _pageTitle:String;
		
		public function SetPageTitleAdvice(pageTitle:String=null){
			this.pageTitle = pageTitle;
		}
	}
}