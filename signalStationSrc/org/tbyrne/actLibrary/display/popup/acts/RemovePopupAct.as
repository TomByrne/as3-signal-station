package org.tbyrne.actLibrary.display.popup.acts
{
	import flash.display.DisplayObject;
	
	import org.tbyrne.actLibrary.display.popup.actTypes.IRemovePopupAct;
	import org.tbyrne.display.popup.IPopupInfo;
	

	public class RemovePopupAct extends AbstractPopupAct implements IRemovePopupAct
	{
		public function RemovePopupAct(popupInfo:IPopupInfo=null){
			super(popupInfo);
		}
	}
}