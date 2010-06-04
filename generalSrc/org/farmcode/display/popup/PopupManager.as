package org.farmcode.display.popup
{
	import au.com.thefarmdigital.utils.DisplayUtils;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	import org.farmcode.actLibrary.display.popup.IModalDisablerView;
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.core.DelayedCall;
	import org.farmcode.instanceFactory.IInstanceFactory;
	
	/** 
	 * The PopupManager class layers DisplayObjects on top of a flash site. It can be instantiated standalone
	 * or provides a global access point if desired.
	 * 
	 * TODO:
	 *  -   Confirm that remove event is fired at the right time.
	 */
	public class PopupManager extends EventDispatcher
	{
		/**
		 * Gets a globally shared instance of the popup manager
		 * 
		 * @return	A PopupManager instance. This istance is shared by all clients accessing the manager
		 * 			via this method
		 */
		public static function get instance(): PopupManager
		{
			if (PopupManager._instance == null)
			{
				PopupManager._instance = new PopupManager();
			}
			return PopupManager._instance;
		}
		/**
		 * Globally available instance of the manager
		 */
		private static var _instance: PopupManager = null;
		
		
		
		
		/**
		 * handler(from:PopupManager, added:IPopupInfo)
		 */
		public function get popupAdded():IAct{
			if(!_popupAdded)_popupAdded = new Act();
			return _popupAdded;
		}
		
		protected var _popupAdded:Act;
		
		/**
		 * handler(from:PopupManager, removed:IPopupInfo)
		 */
		public function get popupRemoved():IAct{
			if(!_popupRemoved)_popupRemoved = new Act();
			return _popupRemoved;
		}
		
		protected var _popupRemoved:Act;
		
		/**
		 * handler(from:PopupManager, from:IPopupInfo, to:IPopupInfo)
		 */
		public function get focusChanged():IAct{
			if(!_focusChanged)_focusChanged = new Act();
			return _focusChanged;
		}
		
		protected var _focusChanged:Act;
		
		
		
		public function get modalDisablerFactory():IInstanceFactory{
			return _modalDisablerFactory;
		}
		public function set modalDisablerFactory(value:IInstanceFactory):void{
			if(_modalDisablerFactory!=value){
				_modalDisablerFactory = value;
				refreshDisablers();
			}
		}
		
		private var _modalDisablerFactory:IInstanceFactory;
		
		/**
		 * If a popups display dispatches a close event, this property determines
		 * whether it should be responded to.
		 */
		public var respondToCloseEvents:Boolean = true;
		
		/**
		 * If the keyboard focus is assigned to a display which is being removed
		 * by the popup manager and reclaimFocus is set to true, the focus will be
		 * assigned to null (allowing the stage to catch keyboard events).
		 */
		public var reclaimFocus:Boolean = true;
		/**
		 * A collection of popups being managed
		 */
		private var _popups:Array = [];
		/**
		 * A collection of focusable popups being managed
		 */
		private var _focusablePopups:Array = [];
		
		/**
		 * A collection of disablers, mapped as parent=>disabler
		 */
		private var _disablers: Dictionary = new Dictionary();
		
		/**
		 * A collection of booleans describing whether a disabler was created from the factory, mapped as parent=>boolean
		 */
		private var _defaultDisablers: Dictionary = new Dictionary(true);
		
		
		
		/**
		 * The top-most popup
		 */
		private var focused: IPopupInfo;
		
		/**
		 * Creates a new popup manager
		 */
		public function PopupManager(){
		}
		
		/**
		 * The addPopup method adds a a Popup DisplayObject to the site, it will be above all other popups 
		 * with the same parent.
		 * If the parent parameter targets another already opened Popup, that Popups parent will be used.
		 * If the Popup dispatches an <code>Event.CLOSE</code> event after it has been added, it will be 
		 * removed. If the Popup is already being managed by this manager then it won't be added again. 
		 * 
		 * @param popupDisplay 			The DisplayObject that will be added (as a Popup to the site.
		 * @param parent 				The DisplayObjectContainer to which the Popup will be added.
		 * @param modal 				Whether or not this Popup is modal (i.e. whether the user can 
		 * 								interact with other parts	of the site before dismissing thiu Popup).
		 * @param center 				Whether the Popups mosition should be changed to center it on the Stage.
		 * @param keepInCentre			If set to true the manager will listen to the "resize" event of the 
		 * 								parent and refresh the popup's position. If center is set to false then 
		 * 								this has no effect
		 * @param positioningOffsets	When positioning the popup, these values will be added to the 
		 * 								calculated position
		 * @param bgFillColour			The fill colour of the mouse blocking area if using modal
		 * @param bgAlpha				The alpha of the fill of the mouse blocking area if using modal
		 * @param bgTransitionTime		The time to transition in the modal popup background
		 * 
		 * @return Whether the popup was successfully added.
		 */
		public function addPopup(popupInfo:IPopupInfo, parent:DisplayObjectContainer):Boolean
		{
			if (popupInfo == null){
				throw new ArgumentError("Parameter popupInfo must be non-null");
			}else if (popupInfo.popupDisplay == null){
				throw new ArgumentError("Parameter popupInfo.popupDisplay must be non-null");
			}else if (parent == null){
				throw new ArgumentError("Parameter popupInfo.parent must be non-null");
			}else if (this.isManaging(popupInfo)){
				// This popup is already being managed, don't re-initialise it
			}else{
				popupInfo.popupDisplay.addEventListener(Event.CLOSE, this.onDisplayCloseEvent);
				
				this._popups.push(popupInfo);
				if(popupInfo.focusable){
					_focusablePopups.push(popupInfo);
				}
				
				// Add in a disabler
				if (popupInfo.isModal){
					setDisabler(parent, popupInfo.modalDisabler, false);
				}
				
				// If popup is already in parent, move to top of order
				if (parent.contains(popupInfo.popupDisplay)){
					parent.setChildIndex(popupInfo.popupDisplay, parent.numChildren - 1);
				}else{
					parent.addChild(popupInfo.popupDisplay);
				}
				
				if(_popupAdded)_popupAdded.perform(this,popupInfo);
				assessFocused();	
				return true;
			}
			
			return false;
		}
		
		
		/**
		 * Triggered when a popup that is being managed is closed
		 * 
		 * @param	e	Details about the close event
		 */
		private function onDisplayCloseEvent(e: Event):void{
			if(respondToCloseEvents){
				var popupInfo:IPopupInfo = findInfoByDisplay(e.target as DisplayObject);
				if(_popupRemoved)_popupRemoved.perform(this,popupInfo);
				finaliseClose(popupInfo);
			}
		}
		protected function findInfoByDisplay(display:DisplayObject):IPopupInfo{
			for each(var popupInfo:IPopupInfo in _popups){
				if(popupInfo.popupDisplay==display){
					return popupInfo;
				}
			}
			return null;
		}
		protected function finaliseClose(popupInfo: IPopupInfo):void{
			var popupIndex: int = _popups.indexOf(popupInfo);
			if (popupIndex >= 0){
				_removePopup(popupInfo, popupIndex);
				assessFocused();
			}
		}
		
		/**
		 * Removes a popup from the site
		 * 
		 * @param	popup	The DisplayObject that was a popup
		 * 
		 * @return	true if the popup was removed successfully, or false if the popup isn't being managed
		 * 			by the manager or it was unable to be removed
		 */
		public function removePopup(popupInfo: IPopupInfo):void
		{
			if(_popupRemoved)_popupRemoved.perform(this,popupInfo);
			popupInfo.popupDisplay.dispatchEvent(new Event(Event.CLOSE));
			if(!respondToCloseEvents){
				finaliseClose(popupInfo);
			}
		}
		protected function _removePopup(popupInfo:IPopupInfo, popupIndex:int):void{
			// The popup is being managed by the manager, remove it
			//var popupInfo: Popup = this._popups[popupIndex] as Popup;
			this._popups.splice(popupIndex, 1);
			var parent: DisplayObjectContainer = popupInfo.popupDisplay.parent;
			if (parent != null)
			{
				var cast:DisplayObjectContainer = popupInfo.popupDisplay as DisplayObjectContainer;
				var focus:DisplayObject = popupInfo.popupDisplay.stage.focus;
				if(focus && reclaimFocus && ((popupInfo.popupDisplay==focus) || (cast && DisplayUtils.isDescendant(cast,focus)))){
					popupInfo.popupDisplay.stage.focus = null;
				}
				
				parent.removeChild(popupInfo.popupDisplay);
			}
			popupInfo.popupDisplay.removeEventListener(Event.CLOSE, this.onDisplayCloseEvent);
			
			// Check disablers and remove if present
			if (popupInfo.isModal)
			{
				var disabler: IModalDisablerView = this._disablers[parent] as IModalDisablerView;
				var dependantPopup: IPopupInfo = this.getHighestModal(parent);
				if(dependantPopup){
					// TODO: Check that this modalDisabler gets added at the correct depth?
					setDisabler(parent,dependantPopup.modalDisabler,false);
					parent.setChildIndex(dependantPopup.popupDisplay,parent.numChildren-1);
				}else{
					removeDisabler(parent);
				}
			}
		}
		
		/**
		 * Removes all popups from the site
		 */
		public function removeAllPopups():void{
			while(_popups.length){
				var popupInfo:IPopupInfo = _popups[0];
				if(_popupRemoved)_popupRemoved.perform(this,popupInfo);
				_removePopup(popupInfo,0);
			}
			assessFocused();
		}
		
		/**
		 * Checks which popup is visually highest, if it has changed since the last check an event is
		 * dispatched.
		 */
		 private function assessFocused():void{
			var upperMostFocusable:IPopupInfo;
			var length:int = _focusablePopups.length;
			if(length){
				upperMostFocusable = _focusablePopups[0];
			 	for(var i:int=1; i<length; ++i){
			 		var compare:IPopupInfo = _focusablePopups[i];
					
					// finds common ancestor
			 		var upperDisplay:DisplayObject = upperMostFocusable.popupDisplay;
			 		var compareDisplay:DisplayObject = compare.popupDisplay;
			 		while(compareDisplay.parent!=upperDisplay.parent && upperDisplay){
			 			while(compareDisplay.parent!=upperDisplay.parent && compareDisplay){
							compareDisplay = compareDisplay.parent;
			 			}
			 			if(compareDisplay.parent!=upperDisplay.parent){
							upperDisplay = upperDisplay.parent;
							compareDisplay = compare.popupDisplay;
			 			}
			 		}
					// compares depths
			 		if(compareDisplay.parent==upperDisplay.parent && compareDisplay.parent != null){
			 			if(compareDisplay.parent.getChildIndex(compareDisplay)>compareDisplay.parent.getChildIndex(upperDisplay)){
			 				upperMostFocusable = compare;
			 			}
			 		}
			 	}
			}
		 	if(upperMostFocusable!=focused){
				var wasFocused:IPopupInfo = focused;
		 		focused = upperMostFocusable;
				if(_focusChanged)_focusChanged.perform(this,wasFocused,focused);
		 	}
		 }
		
		/**
		 * Finds the highest level popup that requires the given disabler. 
		 * 
		 * @param	disabler	The disabler to find the required popup
		 * 
		 * @return	the requiring popup with the highest depth or null if not popups require it
		 */
		private function getHighestModal(parent: DisplayObjectContainer): IPopupInfo
		{
			var highestDependant: IPopupInfo = null;
			
			if (parent != null)
			{
				for (var i: uint = 0; i < this._popups.length; ++i)
				{
					var popup: IPopupInfo = this._popups[i] as IPopupInfo;
					var popupDisplay: DisplayObject = popup.popupDisplay;
					var popupParent: DisplayObjectContainer = popup.popupDisplay.parent;
					if (popup.isModal && parent == popupParent && (highestDependant == null || 
						parent.getChildIndex(popup.popupDisplay) > parent.getChildIndex(highestDependant.popupDisplay))){

						highestDependant = popup;
					}
				}
			}
			
			return highestDependant;
		}
		
		/**
		 * Finds whether the popup Manager is currently managing the given popup
		 * 
		 * @param	popup	The popup to query if being managed
		 * 
		 * @return	true if the popup is being managed, false if not
		 */
		public function isManaging(popupInfo: IPopupInfo): Boolean{
			return _popups.indexOf(popupInfo)!=-1;
		}
		
		
		public function refreshDisablers():void{
			for(var i:* in _disablers){
				if(_defaultDisablers[i]){
					var parent:DisplayObjectContainer = (i as DisplayObjectContainer);
					var disabler:IModalDisablerView = _disablers[i];
					setDisabler(parent, disabler, true);
				}
			}
		}
		protected function setDisabler(parent:DisplayObjectContainer, disabler:IModalDisablerView, forceRefresh:Boolean):void{
			var existing:IModalDisablerView = _disablers[parent];
			var fromDefault:Boolean;
			if(!disabler && _defaultDisablers[parent]){
				disabler = existing;
				fromDefault = true;
			}
			if(_modalDisablerFactory && (!disabler || forceRefresh)){
				disabler = _modalDisablerFactory.createInstance();
				fromDefault = true;
			}

			if(existing!=disabler){
				if(existing){
					var time:Number = existing.removeDisabler();
					if(disabler){
						var delay:DelayedCall = new DelayedCall(disabler.addDisabler,time,true,[parent]);
						delay.begin();
					}
				}else if(disabler){
					disabler.addDisabler(parent);
				}
				if(disabler){
					_disablers[parent] = disabler;
					_defaultDisablers[parent] = fromDefault;
				}else{
					delete _disablers[parent];
					delete _defaultDisablers[parent];
				}
			}else if(disabler){
				disabler.surfaceDisabler();
			}else{
				delete _disablers[parent];
				delete _defaultDisablers[parent];
			}
		}
		protected function removeDisabler(parent:DisplayObjectContainer):void{
			var disabler:IModalDisablerView = _disablers[parent];
			disabler.removeDisabler();
			delete _disablers[parent];
			delete _defaultDisablers[parent];
		}
	}
}