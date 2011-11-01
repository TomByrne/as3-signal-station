package org.tbyrne.composeLibrary.types.display3D
{
	import org.tbyrne.acting.actTypes.IAct;

	public interface I3dTo2dTrait
	{
		/**
		 * handler(from:I3dTo2dTrait, immediate:Boolean)
		 */
		function get requestProjection():IAct;
		function get x3d():Number;
		function get y3d():Number;
		function get z3d():Number;
		
		function setProjectedPoint(x:Number, y:Number, scale:Number, cameraDistance:Number):void;
	}
}