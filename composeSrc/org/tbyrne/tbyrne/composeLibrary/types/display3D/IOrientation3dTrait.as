package org.tbyrne.tbyrne.composeLibrary.types.display3D
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.tbyrne.compose.traits.ITrait;
	
	public interface IOrientation3dTrait extends ITrait
	{
		/**
		 * handler(from:IPosition3dTrait)
		 */
		function get position3dChanged():IAct;
		
		function get posX():Number;
		function get posY():Number;
		function get posZ():Number;
		
		/**
		 * handler(from:IPosition3dTrait)
		 */
		function get rotation3dChanged():IAct;
		
		function get rotX():Number;
		function get rotY():Number;
		function get rotZ():Number;
	}
}