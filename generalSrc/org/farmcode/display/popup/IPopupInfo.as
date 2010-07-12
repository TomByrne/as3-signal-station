package org.farmcode.display.popup
{
	import org.farmcode.actLibrary.display.popup.IModalDisablerView;
	import org.farmcode.display.assets.IDisplayAsset;

	public interface IPopupInfo
	{
		function get popupDisplay():IDisplayAsset;
		
		/**
		 * Whether or not this Popup is modal (i.e. whether the user can 
		 * interact with other parts of the site before dismissing this Popup).
		 */
		function get isModal():Boolean;
		function get modalDisabler():IModalDisablerView;
		
		function get focusable():Boolean;
		function set isFocused(value:Boolean):void;
	}
}