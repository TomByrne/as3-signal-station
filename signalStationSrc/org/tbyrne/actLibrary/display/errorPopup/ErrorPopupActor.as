package org.tbyrne.actLibrary.display.errorPopup
{
	import flash.utils.Dictionary;
	
	import org.tbyrne.actLibrary.core.UniversalActorHelper;
	import org.tbyrne.actLibrary.display.popup.acts.AddPopupAct;
	import org.tbyrne.actLibrary.errors.ErrorDetails;
	import org.tbyrne.actLibrary.errors.ErrorPhases;
	import org.tbyrne.actLibrary.errors.IErrorDisplay;
	import org.tbyrne.actLibrary.errors.actTypes.IDetailedErrorAct;
	import org.tbyrne.actLibrary.errors.actTypes.IErrorAct;
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.universal.UniversalActExecution;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObjectContainer;
	import org.tbyrne.display.popup.PopupInfo;
	
	public class ErrorPopupActor extends UniversalActorHelper
	{
		public var defaultErrorDisplay:IErrorDisplay;
		
		
		public function get popUpParent():IDisplayObjectContainer{
			return _popupAct.parent;
		}
		public function set popUpParent(value:IDisplayObjectContainer):void{
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