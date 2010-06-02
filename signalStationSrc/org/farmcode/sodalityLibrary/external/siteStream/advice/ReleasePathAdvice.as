package org.farmcode.sodalityLibrary.external.siteStream.advice
{
	import flash.events.Event;
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodality.advisors.IAdvisor;
	import org.farmcode.sodalityLibrary.external.siteStream.adviceTypes.IReleasePathAdvice;
	import org.farmcode.sodality.advice.IAdvice;

	public class ReleasePathAdvice extends Advice implements IReleasePathAdvice
	{
		
		[Property(toString="true",clonable="true")]
		public function get releasePath():String{
			return _releasePath;
		}
		public function set releasePath(value:String):void{
			_releasePath = value;
		}
		
		private var _releasePath:String;
		
		public function ReleasePathAdvice(){
			super();
		}
	}
}