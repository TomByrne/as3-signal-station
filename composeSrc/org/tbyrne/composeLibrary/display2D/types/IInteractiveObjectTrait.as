package org.tbyrne.composeLibrary.display2D.types
{
	import flash.display.InteractiveObject;
	
	import org.tbyrne.acting.actTypes.IAct;

	public interface IInteractiveObjectTrait
	{
		/**
		 * handler(from:IInteractiveObjectTrait)
		 */
		function get interactiveObjectChanged():IAct;
		function get interactiveObject():InteractiveObject;
	}
}