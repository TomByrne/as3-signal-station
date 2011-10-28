package org.tbyrne.composeLibrary.types.display3D
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.compose.traits.ITrait;

	public interface IPosition3dTrait extends ITrait
	{
		/**
		 * handler(from:IPosition2dTrait)
		 */
		function get position3dChanged():IAct;
		
		function get x3d():Number;
		function get y3d():Number;
		function get z3d():Number;
		
		function setPosition3d(x:Number, y:Number, z:Number):void;
	}
}