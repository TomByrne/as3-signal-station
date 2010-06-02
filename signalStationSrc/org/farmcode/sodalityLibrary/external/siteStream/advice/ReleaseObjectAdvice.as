package org.farmcode.sodalityLibrary.external.siteStream.advice
{
	import org.farmcode.sodalityLibrary.external.siteStream.adviceTypes.IReleaseObjectAdvice;
	import flash.events.Event;
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodality.advisors.IAdvisor;
	import org.farmcode.sodality.advice.IAdvice;

	public class ReleaseObjectAdvice extends Advice implements IReleaseObjectAdvice
	{
		
		[Property(toString="true",clonable="true")]
		public function get releaseObject():Object{
			return _releaseObject;
		}
		public function set releaseObject(value:Object):void{
			_releaseObject = value;
		}
		
		private var _releaseObject:Object;
		
		public function ReleaseObjectAdvice(){
			super();
		}
	}
}