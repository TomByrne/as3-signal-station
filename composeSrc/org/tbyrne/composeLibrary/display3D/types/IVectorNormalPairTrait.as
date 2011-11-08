package org.tbyrne.composeLibrary.display3D.types
{
	import org.tbyrne.acting.actTypes.IAct;

	public interface IVectorNormalPairTrait
	{
		
		/**
		 * handler(from:IVectorNormalPairTrait)
		 */
		function get vectorNormalChanged():IAct;
		
		function get vectorX():Number;
		function get vectorY():Number;
		function get vectorZ():Number;
		
		function get normalX():Number;
		function get normalY():Number;
		function get normalZ():Number;
	}
}