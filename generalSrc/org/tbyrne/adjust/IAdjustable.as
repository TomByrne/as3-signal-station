package org.tbyrne.adjust
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.display.core.IScopedObject;

	public interface IAdjustable
	{
		
		/**
		 * handler(from:IStylable)
		 */
		function get adjustNamesChanged():IAct;
		
		function get adjustNames():Vector.<String>;
		
		function get adjustDest():*;
		
		function applyAdjustment(property:String, value:*):void;
		function clearAdjustment(property:String):void;
	}
}