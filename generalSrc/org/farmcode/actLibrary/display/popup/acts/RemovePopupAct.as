package org.farmcode.actLibrary.display.popup.acts
{
	import flash.display.DisplayObject;
	
	import org.farmcode.actLibrary.display.popup.actTypes.IRemovePopupAct;
	import org.farmcode.display.popup.IPopupInfo;
	

	public class RemovePopupAct extends AbstractPopupAct implements IRemovePopupAct
	{
		public function RemovePopupAct(popupInfo:IPopupInfo=null){
			super(popupInfo);
		}
	}
}