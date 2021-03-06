package org.tbyrne.composeLibrary.display3D.types
{
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.compose.traits.ITrait;
	
	public interface IMatrix3dTrait extends ITrait
	{
		
		/**
		 * handler(from:IMatrix3dTrait)
		 */
		function get matrix3dChanged():IAct;
		function get matrix3d():Matrix3D;
		function get invMatrix3d():Matrix3D;
	}
}