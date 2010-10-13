package org.tbyrne.siteStream.events
{
	import flash.events.Event;

	public class SiteStreamEvent extends Event
	{
		/* Events
		 Loading events are dispatched for all loading and should not be used to co-ordinate
		 the attaining of data, only for load display etcetera.
		*/
		public static var BEGIN_LOAD:String = "beginLoad";
		public static var FINISH_LOAD:String = "finishLoad";
		public static var LOAD_FAIL:String = "loadFail";
		/**
		 * dispatched after the node and it's children (stubs aside) have finished parsing (but before their references have been resolved).
		 */
		public static var PARSED:String = "parsed";
		/**
		 * dispatched after the node and it's children (stubs aside) have finished parsing and all references have been resolved.
		 */
		public static var RESOLVED:String = "resolved";
		/**
		 * dispatched by SiteStream when a request begins (if dispatchResolvingEvents is set to true).
		 */
		public static var BEGIN_RESOLVE:String = "beginResolve";
		/**
		 * dispatched by SiteStream when a request completes (if dispatchResolvingEvents is set to true).
		 */
		public static var COMPLETE_RESOLVE:String = "completeResolve";
		
		public var object:Object;
		public var path:String;
		
		public function SiteStreamEvent(eventType:String, object:Object=null, path:String=null){
			super(eventType);
			this.object = object;
			this.path = path;
		}
	}
}