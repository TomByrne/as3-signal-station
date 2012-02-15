package org.tbyrne.composeLibrary.controls
{
	import org.tbyrne.acting.actTypes.IAct;

	public interface IRotationControls
	{
		/**
		 * handler(from:ICameraControls)
		 */
		function get rotXChanged():IAct;
		function get rotX():Number;
		function set rotX(value:Number):void;
		/**
		 * handler(from:ICameraControls)
		 */
		function get rotYChanged():IAct;
		function get rotY():Number;
		function set rotY(value:Number):void;
		/**
		 * handler(from:ICameraControls)
		 */
		function get rotZChanged():IAct;
		function get rotZ():Number;
		function set rotZ(value:Number):void;
		/**
		 * handler(from:ICameraControls)
		 */
		function get rotation3dChanged():IAct;
		
		function setRotation3d(x:Number, y:Number, z:Number):void;
	}
}