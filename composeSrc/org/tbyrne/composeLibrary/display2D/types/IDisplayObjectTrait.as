package org.tbyrne.composeLibrary.display2D.types
{
	import flash.display.DisplayObject;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.compose.traits.ITrait;
	
	public interface IDisplayObjectTrait extends ITrait
	{
		
		/**
		 * handler(from:IDisplayObjectTrait, oldDisplayObject:DisplayObject)
		 */
		function get displayObjectChanged():IAct;
		function get displayObject():DisplayObject;
		//function set displayObject(value:DisplayObject):void;
	}
}