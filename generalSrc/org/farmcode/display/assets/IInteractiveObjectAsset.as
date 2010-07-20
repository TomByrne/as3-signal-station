package org.farmcode.display.assets
{
	import org.farmcode.acting.actTypes.IAct;

	public interface IInteractiveObjectAsset extends IDisplayAsset
	{
		
		function get tabEnabled():Boolean;
		function set tabEnabled(value:Boolean):void;
		
		function get mouseEnabled():Boolean;
		function set mouseEnabled(value:Boolean):void;
		
		function get doubleClickEnabled():Boolean;
		function set doubleClickEnabled(value:Boolean):void;
		
		function get tabIndex():int;
		function set tabIndex(value:int):void;
		
		
		/**
		 * handler(from:IInteractiveObjectAsset, mouseActInfo:IMouseActInfo)
		 */
		function get mouseReleased():IAct;
		/**
		 * handler(from:IInteractiveObjectAsset, mouseActInfo:IMouseActInfo)
		 */
		function get mousePressed():IAct;
		/**
		 * handler(from:IInteractiveObjectAsset, mouseActInfo:IMouseActInfo)
		 */
		function get mousedOver():IAct;
		/**
		 * handler(from:IInteractiveObjectAsset, mouseActInfo:IMouseActInfo)
		 */
		function get mousedOut():IAct;
		/**
		 * handler(from:IInteractiveObjectAsset, mouseActInfo:IMouseActInfo)
		 */
		function get rolledOver():IAct;
		/**
		 * handler(from:IInteractiveObjectAsset, mouseActInfo:IMouseActInfo)
		 */
		function get rolledOut():IAct;
		/**
		 * handler(from:IInteractiveObjectAsset, mouseActInfo:IMouseActInfo)
		 */
		function get mouseMoved():IAct;
		/**
		 * handler(from:IInteractiveObjectAsset, mouseActInfo:IMouseActInfo)
		 */
		function get clicked():IAct;
		/**
		 * handler(from:IInteractiveObjectAsset, mouseActInfo:IMouseActInfo)
		 */
		function get doubleClicked():IAct;
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