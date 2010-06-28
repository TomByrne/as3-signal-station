package org.farmcode.display.popup
{
	import au.com.thefarmdigital.utils.DisplayUtils;
	
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import org.farmcode.actLibrary.display.popup.IModalDisablerView;
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.core.DelayedCall;
	import org.farmcode.display.assets.IContainerAsset;
	import org.farmcode.display.assets.IDisplayAsset;
	import org.farmcode.instanceFactory.IInstanceFactory;
	
	/** 
	 * The PopupManager class layers DisplayObjects on top of a flash site. It can be instantiated standalone
	 * or provides a global access point if desired.
	 * 
	 * TODO:
	 *  -   Confirm that remove event is fired at the right time.
	 */
	public class PopupManager
	{
		protected static var instances:Array = [];
		
		protected static function addInstance(popupManager:PopupManager):void{
			instances.push(popupManager);
		}
		
		public static function closePopup(popupDisplay:IDisplayAsset):void{
			for each(var manager:PopupManager in instances){
				if(manager.removePopupByDisplay(popupDisplay)){
					return;
				}
			}
		}
		
		
		
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
			addInstance(this);
		}
		
		/**
		 * The addPopup method adds a Popup IDisplayAsset to the site, it will be above all other popups 
		 * with the same parent.
		 * If the parent parameter targets another already opened Popup, that Popups parent will be used.
		 * If the Popup is already being managed by this manager then it won't be added again. 
		 * 
		 * @param popupInfo 			An object containing details about the popup to be added.
		 * @param parent 				The DisplayObjectContainer to which the Popup will be added.
		 * 
		 * @return Whether the popup was successfully added.
		 */
		public function addPopup(popupInfo:IPopupInfo, parent:IContainerAsset):Boolean
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
					parent.setAssetIndex(popupInfo.popupDisplay, parent.numChildren - 1);
				}else{
					parent.addAsset(popupInfo.popupDisplay);
				}
				
				if(_popupAdded)_popupAdded.perform(this,popupInfo);
				assessFocused();	
				return true;
			}
			
			return false;
		}
		
		/**
		 * Removes a popup from the site
		 * 
		 * @param	popup	The DisplayObject that was a popup
		 */
		public function removePopup(popupInfo: IPopupInfo):void{
			if(_popupRemoved)_popupRemoved.perform(this,popupInfo);
			var popupIndex: int = _popups.indexOf(popupInfo);
			if (popupIndex >= 0){
				_removePopup(popupInfo, popupIndex);
				assessFocused();
			}
		}
		/**
		 * 
		 * @return	true if the popup was removed successfully, or false if the popup isn't being managed
		 * 			by the manager or it was unable to be removed
		 */
		public function removePopupByDisplay(popupDisplay: IDisplayAsset):Boolean{
			var popupInfo:IPopupInfo = findInfoByDisplay(popupDisplay);
			if(popupInfo){
				removePopup(popupInfo);
				return true;
			}else{
				return false;
			}
		}
		protected function _removePopup(popupInfo:IPopupInfo, popupIndex:int=-1):void{
			if(popupIndex==-1){
				popupIndex = _popups.indexOf(popupInfo);
			}
			// The popup is being managed by the manager, remove it
			this._popups.splice(popupIndex, 1);
			var parent: IContainerAsset = popupInfo.popupDisplay.parent;
			if (parent != null)
			{
				var cast:IContainerAsset = popupInfo.popupDisplay as IContainerAsset;
				var focus:IDisplayAsset = popupInfo.popupDisplay.stage.focus;
				if(focus && reclaimFocus && ((popupInfo.popupDisplay==focus) || (cast && DisplayUtils.isDescendant(cast,focus)))){
					popupInfo.popupDisplay.stage.focus = null;
				}
				
				parent.removeAsset(popupInfo.popupDisplay);
			}
			
			// Check disablers and remove if present
			if (popupInfo.isModal)
			{
				var disabler: IModalDisablerView = this._disablers[parent] as IModalDisablerView;
				var dependantPopup: IPopupInfo = this.getHighestModal(parent);
				if(dependantPopup){
					// TODO: Check that this modalDisabler gets added at the correct depth?
					setDisabler(parent,dependantPopup.modalDisabler,false);
					parent.setAssetIndex(dependantPopup.popupDisplay,parent.numChildren-1);
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
			 		var upperDisplay:IDisplayAsset = upperMostFocusable.popupDisplay;
			 		var compareDisplay:IDisplayAsset = compare.popupDisplay;
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
			 			if(compareDisplay.parent.getAssetIndex(compareDisplay)>compareDisplay.parent.getAssetIndex(upperDisplay)){
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
		private function getHighestModal(parent: IContainerAsset): IPopupInfo
		{
			var highestDependant: IPopupInfo = null;
			
			if (parent != null)
			{
				for (var i: uint = 0; i < this._popups.length; ++i)
				{
					var popup: IPopupInfo = this._popups[i] as IPopupInfo;
					var popupDisplay: IDisplayAsset = popup.popupDisplay;
					var popupParent: IContainerAsset = popup.popupDisplay.parent;
					if (popup.isModal && parent == popupParent && (highestDependant == null || 
						parent.getAssetIndex(popup.popupDisplay) > parent.getAssetIndex(highestDependant.popupDisplay))){

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
		public function isManagingByDisplay(popupDisplay:IDisplayAsset):Boolean{
			return (findInfoByDisplay(popupDisplay)!=null)
		}
		protected function findInfoByDisplay(display:IDisplayAsset):IPopupInfo{
			for each(var popupInfo:IPopupInfo in _popups){
				if(popupInfo.popupDisplay==display){
					return popupInfo;
				}
			}
			return null;
		}
		
		
		public function refreshDisablers():void{
			for(var i:* in _disablers){
				if(_defaultDisablers[i]){
					var parent:IContainerAsset = (i as IContainerAsset);
					var disabler:IModalDisablerView = _disablers[i];
					setDisabler(parent, disabler, true);
				}
			}
		}
		protected function setDisabler(parent:IContainerAsset, disabler:IModalDisablerView, forceRefresh:Boolean):void{
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
		protected function removeDisabler(parent:IContainerAsset):void{
			var disabler:IModalDisablerView = _disablers[parent];
			disabler.removeDisabler();
			delete _disablers[parent];
			delete _defaultDisablers[parent];
		}
	}
}