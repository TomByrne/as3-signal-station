package org.tbyrne.display.assets.nativeTypes
{

	import org.tbyrne.acting.actTypes.IAct;
	import flash.display.NativeMenu;
	import flash.display.Stage;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import org.tbyrne.display.assets.assetTypes.IBaseDisplayAsset;

	public interface INativeWindow extends IBaseDisplayAsset
	{
		
		/**
		 * handler(from:INativeWindow)
		 */
		function get activated():IAct;
		
		/**
		 * handler(from:INativeWindow)
		 */
		function get closed():IAct;
		
		/**
		 * handler(from:INativeWindow)
		 */
		function get closing():IAct;
		
		/**
		 * handler(from:INativeWindow)
		 */
		function get deactivate():IAct;
		
		/**
		 * handler(from:INativeWindow)
		 */
		function get displayStateChange():IAct;
		
		/**
		 * handler(from:INativeWindow)
		 */
		function get displayStateChanging():IAct;
		
		/**
		 * handler(from:INativeWindow)
		 */
		function get moved():IAct;
		
		/**
		 * handler(from:INativeWindow)
		 */
		function get moving():IAct;
		
		/**
		 * handler(from:INativeWindow)
		 */
		function get resized():IAct;
		
		/**
		 * handler(from:INativeWindow)
		 */
		function get resizing():IAct;
		
		
		
		
		function get active():Boolean;
		
		function get alwaysInFront():Boolean;
		function set alwaysInFront(value:Boolean):void;
		
		function get bounds():Rectangle;
		function set bounds(value:Rectangle):void;
		
		function get isClosed():Boolean;
		
		function get displayState():String;
		
		function get maximizable():Boolean;
		
		function get maxSize():Point;
		function set maxSize(value:Point):void;
		
		function get menu():NativeMenu;
		function set menu(value:NativeMenu):void;
		
		function get minimizable():Boolean;
		
		function get minSize():Point;
		function set minSize(value:Point):void;
		
		function get resizable():Boolean;
		
		function get systemChrome():String;
		
		function get title():String;
		function set title(value:String):void;
		
		function get transparent():Boolean;
		
		function get type():String;
		
		
		function activate():void;
		function close():void;
		function globalToScreen(globalPoint:Point):Point;
		function maximize():void;
		function minimize():void;
		function notifyUser(type:String):void;
		function orderInBackOf(nativeWindow:INativeWindow):Boolean;
		function orderInFrontOf(nativeWindow:INativeWindow):Boolean;
		function restore():void;
		function startMove():Boolean;
		function startResize(edgeOrCorner:String):Boolean;
	}
}