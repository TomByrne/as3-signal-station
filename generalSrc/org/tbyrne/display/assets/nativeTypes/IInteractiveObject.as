package org.tbyrne.display.assets.nativeTypes
{
	import org.tbyrne.acting.actTypes.IAct;

	public interface IInteractiveObject extends IDisplayObject
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
		 * handler(from:IInteractiveObject, mouseActInfo:IMouseActInfo)
		 */
		function get mouseReleased():IAct;
		/**
		 * handler(from:IInteractiveObject, mouseActInfo:IMouseActInfo)
		 */
		function get mousePressed():IAct;
		/**
		 * handler(from:IInteractiveObject, mouseActInfo:IMouseActInfo)
		 */
		function get mousedOver():IAct;
		/**
		 * handler(from:IInteractiveObject, mouseActInfo:IMouseActInfo)
		 */
		function get mousedOut():IAct;
		/**
		 * handler(from:IInteractiveObject, mouseActInfo:IMouseActInfo)
		 */
		function get rolledOver():IAct;
		/**
		 * handler(from:IInteractiveObject, mouseActInfo:IMouseActInfo)
		 */
		function get rolledOut():IAct;
		/**
		 * handler(from:IInteractiveObject, mouseActInfo:IMouseActInfo)
		 */
		function get mouseMoved():IAct;
		/**
		 * handler(from:IInteractiveObject, mouseActInfo:IMouseActInfo)
		 */
		function get clicked():IAct;
		/**
		 * handler(from:IInteractiveObject, mouseActInfo:IMouseActInfo)
		 */
		function get doubleClicked():IAct;
		/**
		 * handler(from:IInteractiveObject, mouseActInfo:IMouseActInfo, delta:int)
		 */
		function get mouseWheel():IAct;
		
		
		/**
		 * handler(e:FocusEvent, from:IInteractiveObject)
		 */
		function get focusIn():IAct;
		/**
		 * handler(e:FocusEvent, from:IInteractiveObject)
		 */
		function get focusOut():IAct;
		
		
		/**
		 * handler(from:IInteractiveObject, keyActInfo:IKeyActInfo)
		 */
		function get keyDown():IAct;
		/**
		 * handler(from:IInteractiveObject, keyActInfo:IKeyActInfo)
		 */
		function get keyUp():IAct;
		
	}
}