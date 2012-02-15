package org.tbyrne.composeLibrary.controls
{
	import org.tbyrne.acting.actTypes.IAct;

	public interface ICameraControls extends IRotationControls
	{
		/**
		 * handler(from:ICameraControls)
		 */
		function get focalLengthChanged():IAct;
		function get focalLength():Number;
		function set focalLength(value:Number):void;
		/**
		 * handler(from:ICameraControls)
		 */
		function get orthographicChanged():IAct;
		function get orthographic():Boolean;
		function set orthographic(value:Boolean):void;
		
		/**
		 * handler(from:ICameraControls)
		 */
		function get fieldOfViewChanged():IAct;
		function get fieldOfView():Number;
		function set fieldOfView(value:Number):void;
		
		/**
		 * handler(from:ICameraControls)
		 */
		function get posXChanged():IAct;
		function get posX():Number;
		function set posX(value:Number):void;
		/**
		 * handler(from:ICameraControls)
		 */
		function get posYChanged():IAct;
		function get posY():Number;
		function set posY(value:Number):void;
		/**
		 * handler(from:ICameraControls)
		 */
		function get posZChanged():IAct;
		function get posZ():Number;
		function set posZ(value:Number):void;
		
		/**
		 * handler(from:ICameraControls)
		 */
		function get nearDistChanged():IAct;
		function get nearDist():Number;
		function set nearDist(value:Number):void;
		/**
		 * handler(from:ICameraControls)
		 */
		function get farDistChanged():IAct;
		function get farDist():Number;
		function set farDist(value:Number):void;
		
		/**
		 * handler(from:ICameraControls)
		 */
		function get sceneScaleChanged():IAct;
		function get sceneScale():Number;
		function set sceneScale(value:Number):void;
		
		
		/**
		 * handler(from:ICameraControls)
		 */
		function get positionOffsetChanged():IAct;
		function get positionOffset():Number;
		function set positionOffset(value:Number):void;
		
		function setPosition(x:Number, y:Number, z:Number):void;
		
	}
}