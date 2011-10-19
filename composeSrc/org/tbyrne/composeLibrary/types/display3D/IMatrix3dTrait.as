package org.tbyrne.composeLibrary.types.display3D
{
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.compose.traits.ITrait;
	
	public interface IMatrix3dTrait extends ITrait
	{
		
		/**
		 * handler()
		 */
		function get matrix3dChanged():IAct;
		function get matrix3d():Matrix3D;
		function get invMatrix3d():Matrix3D;
	}
}