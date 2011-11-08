package org.tbyrne.composeLibrary.display3D.types
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.compose.traits.ITrait;
	
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