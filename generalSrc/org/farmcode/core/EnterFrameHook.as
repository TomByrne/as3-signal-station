package org.farmcode.core
{
	import flash.display.Shape;
	import flash.events.Event;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.NativeAct;

	public class EnterFrameHook
	{
		private static var frameDispatcher:Shape;
		private static var enterFrameAct:NativeAct;
		
		/**
		 * handler();
		 */
		public static function getAct():IAct{
			if(!frameDispatcher){
				frameDispatcher = new Shape();
				enterFrameAct = new NativeAct(frameDispatcher,Event.ENTER_FRAME,null,false);
			}
			return enterFrameAct;
		}
	}
}