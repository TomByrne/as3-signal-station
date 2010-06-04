package au.com.thefarmdigital.display.popUp
{
	import au.com.thefarmdigital.display.Disabler;
	import au.com.thefarmdigital.utils.DisplayUtils;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	[Event(name="added",type="au.com.thefarmdigital.display.popUp.PopUpEvent")]
	[Event(name="removed",type="au.com.thefarmdigital.display.popUp.PopUpEvent")]
	[Event(name="focusChanged",type="au.com.thefarmdigital.display.popUp.PopUpEvent")]
	/** 
	 * The PopUpManager class layers DisplayObjects on top of a flash site. It can be instantiated standalone
	 * or provides a global access point if desired.
	 * 
	 * TODO:
	 * 	-	Provide option of a disabler style?
	 *  -	Listen to REMOVED event from popUp display incase someone removes it externally
	 */
	public class PopUpManager extends EventDispatcher
	{
		/**
		 * Globally available instance of the manager
		 */
		private static var _instance: PopUpManager = null;
		
		/**
		 * If the keyboard focus is assigned to a display which is being removed
		 * by the popup manager and reclaimFocus is set to true, the focus will be
		 * assigned to null (allowing the stage to catch keyboard events).
		 */
		public var reclaimFocus:Boolean = true;
		/**
		 * A collection of popups being managed
		 */
		private var _popups:Array;
		
		/**
		 * A collection of disablers, mapped as parent=>disabler
		 */
		private var disablers: Dictionary;
		
		private var _respondToCloseEvents:Boolean = true;
		
		
		/**
		 * The top-most popup
		 */
		private var focused: DisplayObject;
		
		/**
		 * Creates a new popup manager
		 */
		public function PopUpManager()
		{
			this._popups = new Array();
			this.disablers = new Dictionary();
		}
		
		public function get numPopups(): uint
		{
			return this.popups.length;
		}
		
		public function get numFocusablePopups(): uint
		{
			return this.focusablePopups.length;
		}
		
		public function get popups(): Array
		{
			return this._popups;
		}
		
		public function get respondToCloseEvents():Boolean{
			return _respondToCloseEvents;
		}
		public function set respondToCloseEvents(value:Boolean):void{
			if(_respondToCloseEvents != value){
				_respondToCloseEvents = value;
			}
		}
		
		/**
		 * The addPopUp method adds a a PopUp DisplayObject to the site, it will be above all other popups 
		 * with the same parent.
		 * If the parent parameter targets another already opened PopUp, that PopUps parent will be used.
		 * If the PopUp dispatches an <code>Event.CLOSE</code> event after it has been added, it will be 
		 * removed. If the PopUp is already being managed by this manager then it won't be added again. 
		 * 
		 * @param popUpDisplay 			The DisplayObject that will be added (as a PopUp to the site.
		 * @param parent 				The DisplayObjectContainer to which the PopUp will be added.
		 * @param modal 				Whether or not this PopUp is modal (i.e. whether the user can 
		 * 								interact with other parts	of the site before dismissing this PopUp).
		 * @param center 				Whether the PopUps mosition should be changed to center it on the Stage.
		 * @param keepInCentre			If set to true the manager will listen to the "resize" event of the 
		 * 								parent and refresh the popUp's position. If center is set to false then 
		 * 								this has no effect
		 * @param positioningOffsets	When positioning the popup, these values will be added to the 
		 * 								calculated position
		 * @param bgFillColour			The fill colour of the mouse blocking area if using modal
		 * @param bgAlpha				The alpha of the fill of the mouse blocking area if using modal
		 * @param bgTransitionTime		The time to transition in the modal popup background
		 * 
		 * @return A reference to the added PopUp.
		 */
		public function addPopUp(popUpDisplay:DisplayObject, parent:DisplayObjectContainer, 
			modal:Boolean=false, centre:Boolean=true, keepInCentre: Boolean = false, 
			positioningOffsets: Point = null, bgFillColour: Number = 0x000000, 
			bgAlpha: Number = 0, bgTransitionTime: Number = 1, focusable: Boolean = true):DisplayObject
		{
			if (popUpDisplay == null)
			{
				throw new ArgumentError("Parameter popUpDisplay must be non-null");
			}
			else if (parent == null)
			{
				throw new ArgumentError("Parameter parent must be non-null");
			}
			else if (this.isManaging(popUpDisplay))
			{
				// This popup is already being managed, don't re-initialise it
				// TODO: Actually should re-centre it and change its params if present
			}
			else
			{
				popUpDisplay.addEventListener(Event.CLOSE, this.handlePopupDisplayCloseEvent);
				
				var popUp: PopUp = new PopUp();
				popUp.centre = centre; 
				popUp.modal = modal; 
				popUp.focusable = focusable; 
				popUp.display = popUpDisplay; 
				popUp.parent = parent;
				popUp.bgFillColour = bgFillColour;
				popUp.bgAlpha = bgAlpha;
				popUp.bgTransitionTime = bgTransitionTime;
				popUp.positioningOffsets = positioningOffsets;
				popUp.keepInCentre = keepInCentre && centre;
				this._popups.push(popUp);
				
				// TODO: Add an Event.REMOVED listener to popUp in case removed externally from parent??
				
				// Add in a disabler
				if (popUp.modal)
				{
					var disabler: Disabler = this.disablers[popUp.parent] as Disabler;
					if (disabler == null)
					{
						disabler = new Disabler();
						disabler.fillColor = popUp.bgFillColour;
						disabler.fillAlpha = popUp.bgAlpha;
						disabler.transitionTime = popUp.bgTransitionTime;
						disabler.show();
						this.disablers[popUp.parent] = disabler;
					}
					
					// If there's already a disabler in the parent, move it to the top
					if (popUp.parent.contains(disabler))
					{
						popUp.parent.setChildIndex(disabler, popUp.parent.numChildren - 1);
					}
					else
					{
						popUp.parent.addChild(disabler);
					}
				}
				
				// If popup is already in parent, move to top of order
				if (popUp.parent.contains(popUpDisplay))
				{
					popUp.parent.setChildIndex(popUpDisplay, popUp.parent.numChildren - 1);
				}
				else
				{
					parent.addChild(popUpDisplay);
				}
				
				// Center the popup in the parent, should we refresh this on parent resize?
				if (popUp.centre)
				{
					if (popUp.keepInCentre)
					{
						popUp.parent.addEventListener(Event.RESIZE, this.handleParentResizeEvent);
					}
					this.centrePopup(popUp);
				}
				dispatchEvent(new PopUpEvent(PopUpEvent.ADDED, popUpDisplay));
				assessFocused();	
			}
			
			return popUpDisplay;
		}
		
		public function isFocusable(popUpDisplay: DisplayObject): Boolean
		{
			var focusable: Boolean = false;
			var popUp: PopUp = this.getPopUpByDisplay(popUpDisplay);
			if (popUp)
			{
				focusable = popUp.focusable;
			}
			return focusable;
		}
		
		/**
		 * Brings the given popup in front of all popups in it's parent.
		 * NOT YET IMPLEMENTED
		 * 
		 * @param	popUpDisplay	The popUp to bring to the front
		 * @return	whether to move to the front was successful
		 */
		public function moveToFront(popUpDisplay: DisplayObject): Boolean
		{
			var found: Boolean = false;
			// TODO:
			return found;
		}
		
		/**
		 * Centres a popup to it's parent dimensions. If the parent is the stage it uses
		 * the stageWidth and stageHeight dimensions instead of width and height
		 * 
		 * @param	popUp	The info of the popup to centre
		 */
		private function centrePopup(popUp: PopUp): void
		{
			var stage:Stage = popUp.display.stage;
			
			var screen:Rectangle = new Rectangle(0,0,stage.stageWidth,stage.stageHeight);
			var alignArea:Rectangle;
			if (popUp.parent==stage && stage.scaleMode == StageScaleMode.NO_SCALE) 
			{
				alignArea = screen;
			}
			else
			{
				alignArea = popUp.parent.getBounds(stage);
				alignArea = alignArea.intersection(screen);
				var offset:Point = popUp.parent.localToGlobal(new Point(0,0));
				alignArea.x -= offset.x;
				alignArea.width -= offset.x;
				alignArea.y -= offset.y;
				alignArea.height -= offset.y;
			}
			popUp.display.x = Math.round(alignArea.x+(alignArea.width - popUp.display.width) / 2);			
			popUp.display.y = Math.round(alignArea.y+(alignArea.height - popUp.display.height) / 2);
			
			if (popUp.positioningOffsets)
			{
				popUp.display.x += popUp.positioningOffsets.x;
				popUp.display.y += popUp.positioningOffsets.y;
			}
		}
		
		/**
		 * Handles a resize event dispatched by a parent within the system
		 *	
		 * @param	event	Details about the resize event
		 */
		private function handleParentResizeEvent(event: Event): void
		{
			var parent: DisplayObjectContainer = event.target as DisplayObjectContainer;
			this.refreshCentredForChildren(parent);
		}
		
		/**
		 * Refreshes the centre position of all popUps marked as centred in the manager
		 * 
		 * @param	parent	If supplied, only update the children of this parent, otherwise refresh
		 * 					all popups
		 */
		private function refreshCentredForChildren(parent: DisplayObjectContainer = null): void
		{
			for (var i: uint = 0; i < this._popups.length; ++i)
			{
				var popUp: PopUp = this._popups[i] as PopUp;
				if (popUp.centre && popUp.keepInCentre && (parent == null || parent == popUp.parent))
				{
					this.centrePopup(popUp);
				}
			}			
		}
		
		/**
		 * Triggered when a popup that is being managed is closed
		 * 
		 * @param	e	Details about the close event
		 */
		private function handlePopupDisplayCloseEvent(e: Event):void
		{
			if(_respondToCloseEvents){
				finaliseClose(e.target as DisplayObject);
			}
		}
		protected function finaliseClose(display:DisplayObject):void{
			var popUpIndex: int = this.getPopupIndex(display);
			if (popUpIndex >= 0){
				_removePopup(popUpIndex);
				assessFocused();
			}
		}
		
		/**
		 * Removes a popup from the site
		 * 
		 * @param	popUp	The DisplayObject that was a popup
		 * 
		 * @return	true if the popup was removed successfully, or false if the popUp isn't being managed
		 * 			by the manager or it was unable to be removed
		 */
		public function removePopup(popUp: DisplayObject):void
		{
			if (popUp == null)
			{
				throw new ArgumentError("Parameter popUp must be non-null");
			}
			else
			{
				popUp.dispatchEvent(new Event(Event.CLOSE));
				if(!_respondToCloseEvents){
					finaliseClose(popUp);
				}
			}
		}
		protected function _removePopup(popUpIndex:int):void{
			// The popup is being managed by the manager, remove it
			var popUpInfo: PopUp = this._popups[popUpIndex] as PopUp;
			this._popups.splice(popUpIndex, 1);
			var parent: DisplayObjectContainer = popUpInfo.parent;
			if (parent != null)
			{
				var cast:DisplayObjectContainer = popUpInfo.display as DisplayObjectContainer;
				var focus:DisplayObject = popUpInfo.display.stage.focus;
				if(focus && reclaimFocus && ((popUpInfo.display==focus) || (cast && DisplayUtils.isDescendant(cast,focus)))){
					popUpInfo.display.stage.focus = null;
				}
				
				parent.removeChild(popUpInfo.display);
				if (!this.isCentredParentPresent(parent)){
					parent.removeEventListener(Event.RESIZE, this.handleParentResizeEvent);
				}
			}
			popUpInfo.display.removeEventListener(Event.CLOSE, this.handlePopupDisplayCloseEvent);
			
			// Check disablers and remove if present
			if (popUpInfo.modal)
			{
				var disabler: Disabler = this.disablers[popUpInfo.parent] as Disabler;
				if (disabler == null)
				{
					// There's an issue, this should match up
				}
				else
				{
					var dependantPopUp: PopUp = this.getHighestDisablerDependant(disabler);
					if (dependantPopUp == null)
					{
						if (popUpInfo.parent.contains(disabler))
						{
							popUpInfo.parent.removeChild(disabler);
						}
						else
						{
							// There's an issue, perhaps some external code removed the disabler
						}
						delete this.disablers[popUpInfo.parent];
					}
					else
					{
						var dependantIndex: uint = dependantPopUp.parentDisplayIndex;
						dependantPopUp.parent.setChildIndex(disabler, dependantIndex);
					}
				}
			}
			
			dispatchEvent(new PopUpEvent(PopUpEvent.REMOVED, popUpInfo.display));	
		}
		
		/**
		 * Removes all popups from the site
		 */
		public function removeAllPopups():void{
			while(_popups.length){
				_removePopup(0);
			}
			assessFocused();
		}
		
		/**
		 * Checks which popup is visually highest, if it has changed since the last check an event is
		 * dispatched.
		 */
		 private function assessFocused():void{
		 	var fPopups: Array = this.focusablePopups;
		 	var upperMostFocusable:DisplayObject = fPopups.length?fPopups[0].display:null;
		 	var length:int = fPopups.length;
		 	for(var i:int=1; i<length; ++i){
		 		var compare:DisplayObject = fPopups[i].display;
		 		
		 		var upperParent:DisplayObject = upperMostFocusable;
		 		var compareParent:DisplayObject = compare;
		 		
		 		while(compareParent.parent!=upperParent.parent && upperParent.parent){
		 			while(compareParent.parent!=upperParent.parent && compareParent.parent){
		 				compareParent = compareParent.parent
		 			}
		 			if(compareParent.parent!=upperParent.parent){
		 				upperParent = upperParent.parent;
		 				compareParent = compare;
		 			}
		 		}
		 		if(compareParent.parent==upperParent.parent && compareParent.parent != null){
		 			if(compareParent.parent.getChildIndex(compareParent)>compareParent.parent.getChildIndex(upperParent)){
		 				upperMostFocusable = compare;
		 			}
		 		}
		 	}
		 	if(upperMostFocusable!=focused){
		 		focused = upperMostFocusable;
		 		dispatchEvent(new PopUpEvent(PopUpEvent.FOCUS_CHANGE, focused));
		 	}
		 }
		
		protected function get focusablePopups(): Array
		{
			var fPopups: Array = new Array();
			for (var i: uint = 0; i < this.popups.length; ++i)
			{
				var popup: PopUp = this.popups[i];
				if (popup.focusable)
				{
					fPopups.push(popup);
				}
			}
			return fPopups;
		}
		
		/**
		 * Finds if there are any popups being managed which are centred and have this container
		 * as a parent.
		 * 
		 * @param	parent	The parent display container to check for
		 * 
		 * @return	true if there is a popup present which is centre aligned and has this parent
		 */
		private function isCentredParentPresent(parent: DisplayObjectContainer): Boolean
		{
			var present: Boolean = false;
			if (parent == null)
			{
				throw new TypeError("Parameter parent must be non-null");
			}
			else
			{
				for (var i: uint = 0; i < this._popups.length && !present; ++i)
				{
					var popUp: PopUp = this._popups[i] as PopUp;
					if (popUp.centre && popUp.keepInCentre && popUp.parent == parent)
					{
						present = true;
					}
				}
			}
			return present;
		}
		
		/**
		 * Finds the highest level popUp that requires the given disabler. 
		 * 
		 * @param	disabler	The disabler to find the required popup
		 * 
		 * @return	the requiring popUp with the highest depth or null if not popUps require it
		 */
		private function getHighestDisablerDependant(disabler: Disabler): PopUp
		{
			var highestDependant: PopUp = null;
			
			var disablerParent: DisplayObjectContainer = disabler.parent;
			if (disablerParent != null)
			{
				for (var i: uint = 0; i < this._popups.length; ++i)
				{
					var popUp: PopUp = this._popups[i] as PopUp;
					var popUpDisplay: DisplayObject = popUp.display;
					var popUpParent: DisplayObjectContainer = popUp.parent;
					if (popUp.modal && disablerParent == popUp.parent && (highestDependant == null || 
						popUp.parentDisplayIndex > popUpParent.getChildIndex(highestDependant.display)))
					{

						highestDependant = popUp;
					}
				}
			}
			
			return highestDependant;
		}
		
		private function getPopUpByDisplay(display: DisplayObject): PopUp
		{
			var popUp: PopUp = null;
			var index: int = this.getPopupIndex(display);
			if (index >= 0)
			{
				popUp = this.popups[index];
			}
			return popUp;
		}
		
		/**
		 * Gets the index of the given popUp in the popups array
		 * 
		 * @param	popUp	The popUp to find the index of
		 * 
		 * @return	the index in the popups array or -1 if it wasn't found
		 */
		private function getPopupIndex(popUpDisplay: DisplayObject): int
		{
			var index: int = -1;
			for (var i: uint = 0; i < this._popups.length && index < 0; ++i)
			{
				var testInfo: PopUp = this._popups[i] as PopUp;
				if (testInfo != null && testInfo.display == popUpDisplay)
				{
					index = i;
				}
			}
			return index;
		}
		
		/**
		 * Finds whether the popup Manager is currently managing the given popup
		 * 
		 * @param	popUp	The popUp to query if being managed
		 * 
		 * @return	true if the popup is being managed, false if not
		 */
		public function isManaging(popUp: DisplayObject): Boolean
		{
			return (this.getPopupIndex(popUp) >= 0);
		}
		
		/**
		 * Gets a globally shared instance of the popup manager
		 * 
		 * @return	A PopUpManager instance. This istance is shared by all clients accessing the manager
		 * 			via this method
		 */
		public static function get instance(): PopUpManager
		{
			if (PopUpManager._instance == null)
			{
				PopUpManager._instance = new PopUpManager();
			}
			return PopUpManager._instance;
		}
	}
}

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import au.com.thefarmdigital.display.Disabler;
import flash.geom.Point;	

/**
 * Holds information about a DisplayObject being tracked as a popup
 */
internal class PopUp
{
	public var display: DisplayObject;
	public var modal: Boolean;
	public var centre: Boolean;
	public var keepInCentre: Boolean;
	public var parent: DisplayObjectContainer;
	public var positioningOffsets: Point;
	public var bgAlpha: Number;
	public var bgFillColour: Number;
	public var bgTransitionTime: Number;
	public var focusable: Boolean;
	
	public function PopUp(display: DisplayObject = null)
	{
		this.display = display;
		this.focusable = true;
		this.modal = false;
		this.centre = true;
		this.parent = null;
		this.keepInCentre = false;
		this.bgAlpha = 0;
		this.bgFillColour = 0;
		this.bgTransitionTime = 1;
		this.positioningOffsets = null;
	}
	
	public function get parentDisplayIndex(): int
	{
		return this.parent.getChildIndex(this.display);
	}
}