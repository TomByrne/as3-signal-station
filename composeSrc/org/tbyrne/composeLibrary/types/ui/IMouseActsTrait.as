package org.tbyrne.composeLibrary.types.ui
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.compose.traits.ITrait;
	import org.tbyrne.data.dataTypes.IBooleanProvider;
	
	public interface IMouseActsTrait extends ITrait
	{
		function get mouseIsOver():IBooleanProvider;
		function get mouseIsDown():IBooleanProvider;
		
		/**
		 * handler(from:IMouseActsTrait)
		 */
		function get mouseClick():IAct;
		
		
		/**
		 * handler(from:IMouseActsTrait)
		 */
		function get mouseDragStart():IAct;
		/**
		 * handler(from:IMouseActsTrait, byX:Number, byY:Number)
		 */
		function get mouseDrag():IAct;
		/**
		 * handler(from:IMouseActsTrait)
		 */
		function get mouseDragFinish():IAct;
		/**
		 * handler(from:IMouseActsTrait, actInfo:IMouseActInfo)
		 */
		function get mouseMoved():IAct;
		
		
		/**
		 * handler(from:IMouseActsTrait)
		 */
		function get mouseLongClick():IAct;
	}
}