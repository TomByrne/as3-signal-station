package org.farmcode.actLibrary.display.popup.actTypes
{
	import flash.display.DisplayObject;
	
	import org.farmcode.acting.actTypes.IUniversalAct;
	import org.farmcode.display.popup.IPopupInfo;
	
	public interface IRemovePopupAct extends IUniversalAct
	{
		function get popupInfo():IPopupInfo;
	}
}