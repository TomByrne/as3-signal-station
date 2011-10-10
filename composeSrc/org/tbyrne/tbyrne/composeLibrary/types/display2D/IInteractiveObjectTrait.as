package org.tbyrne.tbyrne.composeLibrary.types.display2D
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