package org.farmcode.actLibrary.display.errorPopup
{
	import flash.display.DisplayObjectContainer;
	import flash.utils.Dictionary;
	
	import org.farmcode.actLibrary.core.UniversalActorHelper;
	import org.farmcode.actLibrary.display.popup.acts.AddPopupAct;
	import org.farmcode.actLibrary.errors.ErrorDetails;
	import org.farmcode.actLibrary.errors.ErrorPhases;
	import org.farmcode.actLibrary.errors.IErrorDisplay;
	import org.farmcode.actLibrary.errors.actTypes.IDetailedErrorAct;
	import org.farmcode.actLibrary.errors.actTypes.IErrorAct;
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.universal.UniversalActExecution;
	import org.farmcode.display.popup.PopupInfo;
	
	public class ErrorPopupActor extends UniversalActorHelper
	{
		public var defaultErrorDisplay:IErrorDisplay;
		
		
		public function get popUpParent():DisplayObjectContainer{
			return _popupAct.parent;
		}
		public function set popUpParent(value:DisplayObjectContainer):void{
			_popupAct.parent = value;
		}
		
		public function get popupAct():IAct{
			return _popupAct;
		}
		
		private var _popupAct:AddPopupAct = new AddPopupAct();
		private var _popupInfo:PopupInfo = new PopupInfo();
		private var _errorDetailsMap:Dictionary = new Dictionary();
		
		public function ErrorPopupActor(): void{
			super();
			_popupAct.popupInfo = _popupInfo;
			_popupInfo.isModal = true;
			
			metadataTarget = this;
			addChild(_popupAct);
		}
		
		public var onErrorBeforePhases:Array = [ErrorPhases.ERROR_DISPLAY];
		[ActRule(ActClassRule,beforePhases="{onErrorBeforePhases}")]
		public function onError(execution:UniversalActExecution, cause:IErrorAct):void{
			var details:ErrorDetails = _errorDetailsMap[cause.errorType];
			if (details == null && cause is IDetailedErrorAct){
				details = (cause as IDetailedErrorAct).errorDetails;
			}
			if(details){
				var display:IErrorDisplay = details.errorDisplay?details.errorDisplay:defaultErrorDisplay;
				if(display){
					display.errorDetails = details;
					_popupInfo.popupDisplay = display.display;
					_popupAct.perform(execution);
				}
			}
		}
	}
}