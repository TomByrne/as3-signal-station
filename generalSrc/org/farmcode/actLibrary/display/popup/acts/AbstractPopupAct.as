package org.farmcode.actLibrary.display.popup.acts
{
	import flash.display.DisplayObject;
	import flash.utils.Dictionary;
	
	import org.farmcode.actLibrary.display.transition.acts.TransitionAct;
	import org.farmcode.actLibrary.external.siteStream.actTypes.IResolvePathsAct;
	import org.farmcode.display.popup.IPopupInfo;

	public class AbstractPopupAct extends TransitionAct
	{
		public function AbstractPopupAct(popupInfo:IPopupInfo=null){
			this.popupInfo = popupInfo;
		}
		override public function get startDisplay():DisplayObject{
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