package org.tbyrne.actLibrary.display.popup.actTypes
{
	import flash.display.DisplayObject;
	
	import org.tbyrne.acting.actTypes.IUniversalAct;
	import org.tbyrne.display.popup.IPopupInfo;
	
	public interface IRemovePopupAct extends IUniversalAct
	{
		function get popupInfo():IPopupInfo;
	}
}