package org.tbyrne.composeLibrary.types.display3D
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.compose.traits.ITrait;
	
	public interface ICameraDistanceAwareTrait extends ITrait
	{
		
		/**
		 * handler(from:ICameraDistanceAwareTrait)
		 */
		function get cameraDistanceChanged():IAct;
		function get cameraDistance():Number;
		function set cameraDistance(value:Number):void;
	}
}