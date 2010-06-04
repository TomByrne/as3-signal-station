package org.farmcode.actLibrary.display.popup.actTypes
{
	import flash.display.DisplayObjectContainer;
	
	import org.farmcode.acting.actTypes.IUniversalAct;
	import org.farmcode.display.popup.IPopupInfo;
	
	public interface IAddPopupAct extends IUniversalAct
	{
		function get popupInfo():IPopupInfo;
		function get parent():DisplayObjectContainer;
	}
}