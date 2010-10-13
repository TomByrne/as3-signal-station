package org.tbyrne.actLibrary.display.popup
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.display.popup.IPopupInfo;
	import org.tbyrne.display.popup.PopupInfo;
	import org.tbyrne.display.popup.PopupManager;
	
	/**
	 * This class is for use by PopupActor, if you need a PopupManager without any AOP
	 * use the PopupManager directly.
	 * The difference between the two is that instead of removing popups, it performs
	 * an Act and waits for finaliseRemove to be called.
	 */
	public class PassivePopupManager extends PopupManager
	{
		
		/**
		 * handler(from:PassivePopupManager, popupInfo:IPopupInfo)
		 */
		public function get removeAttempted():IAct{
			if(!_removeAttempted)_removeAttempted = new Act();
			return _removeAttempted;
		}
		
		protected var _removeAttempted:Act;
		
		public function PassivePopupManager(){
			super();
		}
		
		override protected function _removePopup(popupInfo:IPopupInfo, popupIndex:int = -1):void{
			if(_removeAttempted){
				_removeAttempted.perform(this,popupInfo);
			}else{
				_removePopup(popupInfo,popupIndex);
			}
		}
		public function finaliseRemove(popupInfo:PopupInfo):void{
			_removePopup(popupInfo);
		}
	}
}