package org.tbyrne.composeLibrary.types.display2D
{
	import flash.display.DisplayObject;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.compose.traits.ITrait;
	
	public interface IDisplayObjectTrait extends ITrait
	{
		
		/**
		 * handler(from:IDisplayObjectTrait)
		 */
		function get displayObjectChanged():IAct;
		function get displayObject():DisplayObject;
		//function set displayObject(value:DisplayObject):void;
	}
}