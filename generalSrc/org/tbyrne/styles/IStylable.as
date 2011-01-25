package org.tbyrne.styles
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.display.core.IScopedObject;

	public interface IStylable extends IScopedObject
	{
		
		/**
		 * handler(from:IStylable)
		 */
		function get styleNamesChanged():IAct;
		
		function get styleNames():Vector.<String>;
		
		function applyStyle(property:String, value:*):void;
		function clearStyle(property:String):void;
	}
}