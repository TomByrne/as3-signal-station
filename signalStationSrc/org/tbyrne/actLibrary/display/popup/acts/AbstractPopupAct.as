package org.tbyrne.actLibrary.display.popup.acts
{
	import org.tbyrne.actLibrary.display.transition.acts.TransitionAct;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
	import org.tbyrne.display.popup.IPopupInfo;

	public class AbstractPopupAct extends TransitionAct
	{
		public function AbstractPopupAct(popupInfo:IPopupInfo=null){
			this.popupInfo = popupInfo;
		}
		override public function get startDisplay():IDisplayObject{
			return _popupInfo?_popupInfo.popupDisplay:null;
		}
		
		private var _popupInfo:IPopupInfo;
		protected var _resolveSuccessful:Boolean;
		
		public function get popupInfo():IPopupInfo{
			return _popupInfo;
		}
		public function set popupInfo(value:IPopupInfo):void{
			_popupInfo = value;
		}
	}
}