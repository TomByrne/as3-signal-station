package org.farmcode.display.popup
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Point;
	
	import org.farmcode.actLibrary.display.popup.IModalDisablerView;
	import org.farmcode.display.ISelfAnimatingView;

	public interface IPopupInfo
	{
		function get popupDisplay():DisplayObject;
		
		function get isModal():Boolean;
		function get modalDisabler():IModalDisablerView;
		
		function get focusable():Boolean;
		function set isFocused(value:Boolean):void;
	}
}