package org.farmcode.display.assets
{
	import org.farmcode.acting.actTypes.IAct;

	public interface IInteractiveObjectAsset extends IDisplayAsset
	{
		
		function get tabEnabled():Boolean;
		function set tabEnabled(value:Boolean):void;
		
		function get mouseEnabled():Boolean;
		function set mouseEnabled(value:Boolean):void;
		
		function get tabIndex():int;
		function set tabIndex(value:int):void;
		
		
		/**
		 * handler(from:IInteractiveObjectAsset, mouseActInfo:IMouseActInfo)
		 */
		function get mouseDown():IAct;
		/**
		 * handler(from:IInteractiveObjectAsset, mouseActInfo:IMouseActInfo)
		 */
		function get mouseUp():IAct;
		/**
		 * handler(from:IInteractiveObjectAsset, mouseActInfo:IMouseActInfo)
		 */
		function get mouseOver():IAct;
		/**
		 * handler(from:IInteractiveObjectAsset, mouseActInfo:IMouseActInfo)
		 */
		function get mouseOut():IAct;
		/**
		 * handler(from:IInteractiveObjectAsset, mouseActInfo:IMouseActInfo)
		 */
		function get rollOver():IAct;
		/**
		 * handler(from:IInteractiveObjectAsset, mouseActInfo:IMouseActInfo)
		 */
		function get rollOut():IAct;
		/**
		 * handler(from:IInteractiveObjectAsset, mouseActInfo:IMouseActInfo)
		 */
		function get mouseMove():IAct;
		/**
		 * handler(from:IInteractiveObjectAsset, mouseActInfo:IMouseActInfo)
		 */
		function get click():IAct;
		/**
		 * handler(from:IInteractiveObjectAsset, mouseActInfo:IMouseActInfo, delta:int)
		 */
		function get mouseWheel():IAct;
		
		
		/**
		 * handler(e:FocusEvent, from:IInteractiveObjectAsset)
		 */
		function get focusIn():IAct;
		/**
		 * handler(e:FocusEvent, from:IInteractiveObjectAsset)
		 */
		function get focusOut():IAct;
		
		
		/**
		 * handler(e:KeyboardEvent, from:IInteractiveObjectAsset)
		 */
		function get keyDown():IAct;
		/**
		 * handler(e:KeyboardEvent, from:IInteractiveObjectAsset)
		 */
		function get keyUp():IAct;
		
	}
}