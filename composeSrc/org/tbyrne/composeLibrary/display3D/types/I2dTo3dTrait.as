package org.tbyrne.composeLibrary.display3D.types
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.compose.traits.ITrait;
	
	public interface I2dTo3dTrait extends ITrait
	{
		/**
		 * handler(from:I2dTo3dTrait, immediate:Boolean)
		 */
		function get requestUnprojection():IAct;
		function get x2d():Number;
		function get y2d():Number;
		
		// must include either cameraDistance or planeTransform
		function get cameraDistance():Number;
		function get planeTransform():IMatrix3dTrait;
		
		function setUnprojectedPoint(x:Number, y:Number, z:Number):void;
	}
}