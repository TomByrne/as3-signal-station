package org.tbyrne.composeLibrary.adjust.types
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.compose.traits.ITrait;
	
	public interface ITogglableTrait extends ITrait
	{
		function get togglableGroup():String;
		
		function get isToggled():Boolean;
		function set isToggled(value:Boolean):void;
		
		
		/**
		 * handler(from:ITogglableTrait)
		 */
		function get isToggledChanged():IAct;
	}
}