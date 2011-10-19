package org.tbyrne.composeLibrary.types.display2D
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.compose.traits.ITrait;

	public interface IPosition2dTrait extends ITrait
	{
		/**
		 * handler(from:IPosition2dTrait)
		 */
		function get position2dChanged():IAct;
		function get x():Number;
		function get y():Number;
		function setPosition2d(x:Number, y:Number):void;
	}
}