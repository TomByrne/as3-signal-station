package org.farmcode.actLibrary.display.popup
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import org.farmcode.actLibrary.core.UniversalActorHelper;
	import org.farmcode.actLibrary.display.DisplayPhases;
	import org.farmcode.actLibrary.display.popup.actTypes.IAddPopupAct;
	import org.farmcode.actLibrary.display.popup.actTypes.IRemoveAllPopupsAct;
	import org.farmcode.actLibrary.display.popup.actTypes.IRemovePopupAct;
	import org.farmcode.actLibrary.display.popup.acts.RemovePopupAct;
	import org.farmcode.display.popup.IPopupInfo;
	import org.farmcode.display.popup.PopupManager;
	import org.farmcode.instanceFactory.IInstanceFactory;
	import org.farmcode.utils.MethodCallQueue;

	public class PopupActor extends UniversalActorHelper
	{
		override public function set scopeDisplay(value:DisplayObject):void{
			super.scopeDisplay = value;
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
		
		
		protected var popupManager:PopupManager;
		private var _pendingPopUps:Dictionary = new Dictionary(true);
		private var _openPopUps:Dictionary = new Dictionary(true);
		private var _removePopup:RemovePopupAct = new RemovePopupAct();
		
		public function PopupActor(modalDisablerFactory:IInstanceFactory=null){
			super();
			popupManager = new PopupManager();
			popupManager.respondToCloseEvents = false;
			popupManager.modalDisablerFactory = modalDisablerFactory;
			
			addChild(_removePopup);
			
			metadataTarget = this;
		}
		
		public var addPopupPhases:Array = [PopupPhases.ADD_POPUP,DisplayPhases.DISPLAY_ADDED,DisplayPhases.DISPLAY_CHANGED];
		[ActRule(ActClassRule)]
		[ActReaction(phases="{addPopupPhases}")]
		public function addPopup(cause:IAddPopupAct):void{
			var popupInfo:IPopupInfo = cause.popupInfo;
			
			var parent:DisplayObjectContainer = (cause.parent || (_scopeDisplay as DisplayObjectContainer));
				
			if(popupInfo.popupDisplay){
				if(parent){
					popupInfo.popupDisplay.addEventListener(Event.CLOSE, onCloseRequest, false, int.MAX_VALUE);
					_openPopUps[popupInfo.popupDisplay] = popupInfo;
					popupManager.addPopup(popupInfo,parent);
				}else{
					_pendingPopUps[popupInfo] = true;
				}
			}else{
				throw new Error("Cannot add null popup");
			}
		}
		
		public var removePopupPhases:Array = [PopupPhases.REMOVE_POPUP,DisplayPhases.DISPLAY_REMOVED,DisplayPhases.DISPLAY_CHANGED];
		[ActRule(ActClassRule)]
		[ActReaction(phases="{removePopupPhases}")]
		public function removePopup(cause:IRemovePopupAct):void{
			var popupInfo:IPopupInfo = cause.popupInfo;
			
			if(_pendingPopUps[popupInfo]){
				delete _pendingPopUps[popupInfo];
			}else{
				popupInfo.popupDisplay.removeEventListener(Event.CLOSE, onCloseRequest);
				delete _openPopUps[popupInfo.popupDisplay];
				popupManager.removePopup(popupInfo);
			}
		}
		protected function onCloseRequest(e:Event):void{
			var popupDisplay:DisplayObject = e.target as DisplayObject;
			_removePopup.popupInfo = _openPopUps[popupDisplay];
			_removePopup.perform();
		}
		
		[ActRule(ActClassRule)]
		[ActReaction(phases="{removePopupPhases}")]
		public function removeAllPopups(cause:IRemoveAllPopupsAct):void{
			for each(var popupInfo:IPopupInfo in _openPopUps){
				popupInfo.popupDisplay.removeEventListener(Event.CLOSE, onCloseRequest);
			}
			_openPopUps = new Dictionary();
			popupManager.removeAllPopups();
		}
	}
}