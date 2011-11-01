package org.tbyrne.composeLibrary.tools.moveSelection
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.compose.traits.ITrait;

	public interface IMoveTrait extends ITrait
	{
		
		/**
		 * handler(from:IMoveTrait)
		 */
		function get isMovingChanged():IAct;
		function get isMoving():Boolean;
		function set isMoving(value:Boolean):void;
	}
}