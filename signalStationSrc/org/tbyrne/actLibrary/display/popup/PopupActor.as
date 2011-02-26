package org.tbyrne.actLibrary.display.popup
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import org.tbyrne.actLibrary.core.UniversalActorHelper;
	import org.tbyrne.actLibrary.display.DisplayPhases;
	import org.tbyrne.actLibrary.display.popup.actTypes.IAddPopupAct;
	import org.tbyrne.actLibrary.display.popup.actTypes.IRemoveAllPopupsAct;
	import org.tbyrne.actLibrary.display.popup.actTypes.IRemovePopupAct;
	import org.tbyrne.actLibrary.display.popup.acts.RemovePopupAct;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObjectContainer;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
	import org.tbyrne.display.popup.IPopupInfo;
	import org.tbyrne.instanceFactory.IInstanceFactory;

	public class PopupActor extends UniversalActorHelper
	{
		override public function set asset(value:IDisplayObject):void{
			super.asset = value;
			if(value){
				for each(var cause:IAddPopupAct in _pendingPopUps){
					addPopup(cause);
				}
				_pendingPopUps = new Dictionary(true);
			}
		}
		/**
		 * If the keyboard focus is assigned to a display which is being removed
		 * by the popup manager and reclaimFocus is set to true, the focus will be
		 * assigned to null (allowing the stage to catch keyboard events).
		 */
		public function get reclaimFocus():Boolean{
			return popupManager.reclaimFocus;
		}
		public function set reclaimFocus(value:Boolean):void{
			popupManager.reclaimFocus = value;
		}
		public function get modalDisablerFactory():IInstanceFactory{
			return popupManager.modalDisablerFactory;
		}
		public function set modalDisablerFactory(value:IInstanceFactory):void{
			popupManager.modalDisablerFactory = value;
		}
		
		
		protected var popupManager:PassivePopupManager;
		private var _pendingPopUps:Dictionary = new Dictionary(true);
		private var _removePopup:RemovePopupAct = new RemovePopupAct();
		
		public function PopupActor(modalDisablerFactory:IInstanceFactory=null){
			super();
			popupManager = new PassivePopupManager();
			popupManager.removeAttempted.addHandler(onRemoveAttempted);
			popupManager.modalDisablerFactory = modalDisablerFactory;
			
			addChild(_removePopup);
			
			metadataTarget = this;
		}
		
		public var addPopupPhases:Array = [PopupPhases.ADD_POPUP,DisplayPhases.DISPLAY_ADDED,DisplayPhases.DISPLAY_CHANGED];
		[ActRule(ActClassRule)]
		[ActReaction(phases="<addPopupPhases>")]
		public function addPopup(cause:IAddPopupAct):void{
			var popupInfo:IPopupInfo = cause.popupInfo;
			
			var parent:IDisplayObjectContainer = (cause.parent || (_asset as IDisplayObjectContainer));
				
			if(popupInfo.popupDisplay){
				if(parent){
					popupManager.addPopup(popupInfo,parent);
				}else{
					_pendingPopUps[popupInfo] = true;
				}
			}else{
				Log.error( "PopupActor.addPopup: Cannot add null popup");
			}
		}
		
		public var removePopupPhases:Array = [PopupPhases.REMOVE_POPUP,DisplayPhases.DISPLAY_REMOVED,DisplayPhases.DISPLAY_CHANGED];
		[ActRule(ActClassRule)]
		[ActReaction(phases="<removePopupPhases>")]
		public function removePopup(cause:IRemovePopupAct):void{
			var popupInfo:IPopupInfo = cause.popupInfo;
			
			if(_pendingPopUps[popupInfo]){
				delete _pendingPopUps[popupInfo];
			}else{
				popupManager.removePopup(popupInfo);
			}
		}
		protected function onRemoveAttempted(from:PassivePopupManager, popupInfo:IPopupInfo):void{
			_removePopup.popupInfo = popupInfo
			_removePopup.perform();
		}
		
		[ActRule(ActClassRule)]
		[ActReaction(phases="<removePopupPhases>")]
		public function removeAllPopups(cause:IRemoveAllPopupsAct):void{
			popupManager.removeAllPopups();
		}
	}
}