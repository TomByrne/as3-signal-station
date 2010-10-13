package org.tbyrne.core
{
	import flash.display.Shape;
	import flash.events.Event;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.NativeAct;

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