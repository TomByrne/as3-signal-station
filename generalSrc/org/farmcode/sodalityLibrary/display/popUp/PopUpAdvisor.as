package org.farmcode.sodalityLibrary.display.popUp
{
	import org.farmcode.display.popup.PopupManager;
	import org.farmcode.sodality.advisors.DynamicAdvisor;
	import org.farmcode.sodality.events.AdviceEvent;
	import org.farmcode.actLibrary.display.popup.acts.RemovePopupAct;
	import org.farmcode.sodalityLibrary.display.popUp.adviceTypes.IAddPopUpAdvice;
	import org.farmcode.actLibrary.display.popup.actTypes.IAdvancedAddPopupAct;
	import org.farmcode.actLibrary.display.popup.actTypes.IRemoveAllPopupsAct;
	import org.farmcode.actLibrary.display.popup.actTypes.IRemovePopupAct;
	import org.farmcode.actLibrary.display.transition.actTypes.ITransitionAct;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.Dictionary;

	public class PopUpAdvisor extends DynamicAdvisor
	{
		public function get defaultParent():DisplayObjectContainer{
			return _defaultParent;
		}
		public function set defaultParent(value:DisplayObjectContainer):void{
			if(value!=_defaultParent){
				_defaultParent = value;
				var pend:Dictionary = pendingPopUps;
				pendingPopUps = new Dictionary();
				for each(var cause:IAddPopUpAdvice in pend){
					addPopUp(cause);
				}
			}
		}
		/**
		 * If the keyboard focus is assigned to a display which is being removed
		 * by the popup manager and reclaimFocus is set to true, the focus will be
		 * assigned to null (allowing the stage to catch keyboard events).
		 */
		public function get reclaimFocus():Boolean{
			return popUpManager.reclaimFocus;
		}
		public function set reclaimFocus(value:Boolean):void{
			popUpManager.reclaimFocus = value;
		}
		
		
		protected var popUpManager:PopupManager;
		private var _defaultParent:DisplayObjectContainer;
		private var pendingPopUps:Dictionary = new Dictionary(true);
		private var openPopUps:Dictionary = new Dictionary(true);
		
		public function PopUpAdvisor(){
			super();
			popUpManager = new PopupManager();
			popUpManager.respondToCloseEvents = false;
		}
		
		[Trigger(triggerTiming="before")]
		public function onBeforeAddPopUp(cause:IAddPopUpAdvice):void{
			cause.addEventListener(AdviceEvent.EXECUTE, onAddPopUp);
		}
		protected function onAddPopUp(e:AdviceEvent):void{
			var cause:IAddPopUpAdvice = (e.target as IAddPopUpAdvice);
			addPopUp(cause);
		}
		protected function addPopUp(cause:IAddPopUpAdvice):void{
			var parent:DisplayObjectContainer = _defaultParent;
			var centre:Boolean = true;
			var focusable:Boolean = true;
			var keepInCentre:Boolean = false;
			var offsets:Point;
			var bgFillColour:Number = 0;
			var bgAlpha:Number = 0;
			var bgTransitionTime:Number = 0;
			if(cause is IAdvancedAddPopupAct){
				var adv:IAdvancedAddPopupAct = (cause as IAdvancedAddPopupAct);
				if(adv.popUpParent)parent = adv.popUpParent;
				centre = adv.centre;
				keepInCentre = adv.keepInCentre;
				focusable = adv.focusable;
				if(adv.positioningOffsets)offsets = adv.positioningOffsets;
				if(!isNaN(adv.bgFillColour))bgFillColour = adv.bgFillColour;
				if(!isNaN(adv.bgAlpha))bgAlpha = adv.bgAlpha;
				if(!isNaN(adv.bgTransitionTime))bgTransitionTime = adv.bgTransitionTime;
			}
			if(cause.display){
				if(parent){
					cause.display.addEventListener(Event.CLOSE, onCloseRequest, false, int.MAX_VALUE);
					openPopUps[cause.display] = cause;
					popUpManager.addPopUp(cause.display, parent, cause.modal, centre, keepInCentre, offsets, 
						bgFillColour, bgAlpha, bgTransitionTime, focusable);
				}else{
					pendingPopUps[cause.display] = cause;
				}
			}
			else
			{
				throw new Error("Cannot add null popup");
			}
		}
		[Trigger(triggerTiming="before")]
		public function onBeforeRemovePopUp(cause:IRemovePopupAct):void{
			cause.addEventListener(AdviceEvent.EXECUTE, onRemovePopUp);
		}
		protected function onRemovePopUp(e:AdviceEvent):void{
			var cause:IRemovePopupAct = (e.target as IRemovePopupAct);
			cause.removeEventListener(AdviceEvent.EXECUTE, onRemovePopUp);
			if(pendingPopUps[cause.display]){
				delete pendingPopUps[cause.display];
			}else{
				cause.display.removeEventListener(Event.CLOSE, onCloseRequest);
				delete openPopUps[cause.display];
				popUpManager.removePopup(cause.display);
			}
		}
		protected function onCloseRequest(e:Event):void{
			var popUp:DisplayObject = e.target as DisplayObject;
			
			var addAdvice: IAddPopUpAdvice = this.openPopUps[popUp];
			var advice:RemovePopupAct = new RemovePopupAct(null, popUp);
			if (addAdvice is ITransitionAct)
			{
				var tranAddAdvice: ITransitionAct = addAdvice as ITransitionAct;
				advice.doTransition = tranAddAdvice.doTransition;
			}
			dispatchEvent(advice);
		}
		
		[Trigger(triggerTiming="before")]
		public function onBeforeRemoveAllPopUps(cause:IRemoveAllPopupsAct):void{
			cause.addEventListener(AdviceEvent.EXECUTE, onRemoveAllPopUps);
		}
		protected function onRemoveAllPopUps(e:AdviceEvent):void{
			var cause:IRemoveAllPopupsAct = (e.target as IRemoveAllPopupsAct);
			cause.removeEventListener(AdviceEvent.EXECUTE, onRemoveAllPopUps);
			popUpManager.removeAllPopups();
		}
	}
}