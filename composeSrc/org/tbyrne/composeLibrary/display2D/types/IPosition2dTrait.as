package org.tbyrne.composeLibrary.display2D.types
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.compose.traits.ITrait;

	public interface IPosition2dTrait extends ITrait
	{
		/**
		 * handler(from:IPosition2dTrait)
		 */
		function get position2dChanged():IAct;
		function get x2d():Number;
		function get y2d():Number;
		function setPosition2d(x:Number, y:Number):void;
	}
}