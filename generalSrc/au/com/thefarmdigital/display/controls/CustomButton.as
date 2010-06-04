package au.com.thefarmdigital.display.controls
{
	import au.com.thefarmdigital.events.ControlEvent;
	import au.com.thefarmdigital.validation.ValidationEvent;
	
	import flash.display.DisplayObject;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	
	/**
	 * <p>The CustomButton control allows for an arbitrarily designed/sized button which can
	 * still be integrated with the Farm control Library (with Forms, Validators etc).</p>
	 * <p>The CustomButton control is the superclass of all buttons in the Farm control library.
	 * The display of buttons in CustomButtons (and it's subclasses) is based around specific
	 * visual states:</p>
	 * <ul>
	 * 	<li>upState (the only state which every CustomButton must have)</li>
	 * 	<li>overState</li>
	 * 	<li>downState</li>
	 * 	<li>highlightState</li>
	 * 	<li>selectedUpState</li>
	 * 	<li>selectedOverState</li>
	 * 	<li>selectedDownState</li>
	 * 	<li>selectedHighlightState</li>
	 * 	<li>disabledState</li>
	 * </ul>
	 * <p>Each of these state names is stored as static constant, these can be used in conjunction
	 * with the getState (inherited from the StateControl class) to get a reference to the
	 * VisualState object representing each of these states.</p>
	 */
	public class CustomButton extends StateControl
	{
		// States
		public static const UP_STATE:String = "upState";
		public static const OVER_STATE:String = "overState";
		public static const DOWN_STATE:String = "downState";
		public static const HIGHLIGHT_STATE:String = "highlightState";
		public static const DISABLED_STATE:String = "disabledState";
		public static const SELECTED_UP_STATE:String = "selectedUpState";
		public static const SELECTED_OVER_STATE:String = "selectedOverState";
		public static const SELECTED_DOWN_STATE:String = "selectedDownState";
		public static const SELECTED_HIGHLIGHT_STATE:String = "selectedHighlightState";
		
		[Inspectable(defaultValue=false, type="Boolean", name="Togglable")]
		public function get autoToggleSelect():Boolean{
			return _autoToggleSelect;
		}
		public function set autoToggleSelect(value:Boolean):void{
			_autoToggleSelect = value;
		}
		
		[Inspectable(defaultValue=false, type="Boolean", name="Selected")]
		public function get selected():Boolean{
			return this._selected;
		}
		public function set selected(value:Boolean):void {
			if(this.selected != value){
				_selected = value;
				dispatchEvent(new ControlEvent(ControlEvent.BUTTON_TOGGLE));
				dispatchEvent(new ControlEvent(ValidationEvent.VALIDATION_VALUE_CHANGED));
				invalidate();
			}
		}
		public function get upState():DisplayObject{
			return _upState;
		}
		public function set upState(value:DisplayObject):void{
			if(this.upState!=value){
				removeState(UP_STATE);
				_upState = value;
				addState(new VisualState(UP_STATE,value));
				invalidate();
			}
		}
		public function get overState():DisplayObject{
			return _overState;
		}
		public function set overState(value:DisplayObject):void{
			if(this.overState!=value){
				removeState(OVER_STATE);
				_overState = value;
				if(value) this.focusRect = false;
				else this.focusRect = true;
				addState(new VisualState(OVER_STATE,value));
				invalidate();
			}
		}
		public function get downState():DisplayObject{
			return _downState;
		}
		public function set downState(value:DisplayObject):void{
			if(this.downState!=value){
				removeState(DOWN_STATE);
				_downState = value;
				addState(new VisualState(DOWN_STATE,value));
				invalidate();
			}
		}
		public function get highlightState():DisplayObject{
			return _highlightState;
		}
		public function set highlightState(value:DisplayObject):void{
			if(this.highlightState!=value){
				removeState(HIGHLIGHT_STATE);
				_highlightState = value;
				addState(new VisualState(HIGHLIGHT_STATE,value));
				invalidate();
			}
		}
		public function get selectedUpState():DisplayObject{
			return _selectedUpState;
		}
		public function set selectedUpState(value:DisplayObject):void{
			if(this.selectedUpState!=value){
				removeState(SELECTED_UP_STATE);
				_selectedUpState = value;
				addState(new VisualState(SELECTED_UP_STATE,value));
				invalidate();
			}
		}
		public function get selectedOverState():DisplayObject{
			return _selectedOverState;
		}
		public function set selectedOverState(value:DisplayObject):void{
			if(this.selectedOverState!=value){
				removeState(SELECTED_OVER_STATE);
				_selectedOverState = value;
				addState(new VisualState(SELECTED_OVER_STATE,value));
				invalidate();
			}
		}
		public function get selectedDownState():DisplayObject{
			return _selectedDownState;
		}
		public function set selectedDownState(value:DisplayObject):void{
			if(this.selectedDownState!=value){
				removeState(SELECTED_DOWN_STATE);
				_selectedDownState = value;
				addState(new VisualState(SELECTED_DOWN_STATE,value));
				invalidate();
			}
		}
		public function get selectedHighlightState():DisplayObject{
			return _selectedHighlightState;
		}
		public function set selectedHighlightState(value:DisplayObject):void{
			if(this.selectedHighlightState!=value){
				removeState(SELECTED_HIGHLIGHT_STATE);
				_selectedHighlightState = value;
				addState(new VisualState(SELECTED_HIGHLIGHT_STATE,value));
				invalidate();
			}
		}
		public function get disabledState():DisplayObject{
			return _disabledState;
		}
		public function set disabledState(value:DisplayObject):void{
			if(this.disabledState!=value){
				removeState(DISABLED_STATE);
				_disabledState = value;
				addState(new VisualState(DISABLED_STATE,value));
				invalidate();
			}
		}
		
		[Inspectable(defaultValue=true, type="Boolean", name="Enabled")]
		public function get enabled():Boolean{
			return super.buttonMode;
		}
		public function set enabled(value:Boolean):void{
			super.buttonMode = value;
			invalidate();
		}
		
		override public function getValidationValue(validityKey:String=null):*{
			return selected;
		}
		override public function setValidationValue(value:*, validityKey:String=null):void{
			selected = value;
		}
		
		public function get mouseOver(): Boolean
		{
			return this._over;
		}
		
		public function get mouseDown(): Boolean
		{
			return this._down;
		}
		
		protected var _upState:DisplayObject;
		protected var _overState:DisplayObject;
		protected var _downState:DisplayObject;
		protected var _highlightState:DisplayObject;
		protected var _disabledState:DisplayObject;
		
		protected var _selectedUpState:DisplayObject;
		protected var _selectedOverState:DisplayObject;
		protected var _selectedDownState:DisplayObject;
		protected var _selectedHighlightState:DisplayObject;
		
		private var _over:Boolean = false;
		private var _down:Boolean = false;
		private var _selected:Boolean = false;
		private var _autoToggleSelect:Boolean = false;
		
		/**
		 * The CustomButton class is used for buttons with a completely custom look, it differs to the flash.display.SimpleButton class in 
		 * that it can has all the benefits of it's Control superclass (e.g. validation, integration with the Form class, etc.) as well as
		 * being togglable. The CheckBox and Button controls are both subclasses of this class and therefore have access to the same states
		 * The CustomButton does not manage a label and icon, use the au.com.thefarmdigital.display.controls.Button class if you need these.
		 * 
		 * To prepare a CustomButton in Flash, target this class in the Symbol's properties, and have instances within the Symbol with names
		 * matching the following states.
		 * 
		 * These are the states of the CustomButton:
		 * - upState
		 * - overState
		 * - downState
		 * - highlightState
		 * - disabledState
		 * - selectedUpState
		 * - selectedOverState
		 * - selectedDownState
		 * - selectedHighlightState
		 */
		public function CustomButton(){
			super();
			tabEnabled = true;
			buttonMode = true;
			useHandCursor = true;
			mouseChildren = false;
			addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
			addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			addEventListener(MouseEvent.CLICK, onClick); // MouseEvent.MOUSE_UP doesn't catch the enter button
			
			addEventListener(FocusEvent.FOCUS_IN,onSetFocus);
			addEventListener(FocusEvent.FOCUS_OUT,onKillFocus);
		}
		override public function clear():void{
			selected = false;
		}
		protected function rollOverHandler(e:MouseEvent):void{
			if(enabled && !this.mouseOver){
				_over = true;
				invalidate();
			}
		}
		protected function rollOutHandler(e:MouseEvent):void{
			if(this.mouseOver){
				_over = false;
				invalidate();
			}
		}
		protected function onMouseDown(e:MouseEvent):void{
			if(enabled && !this.mouseDown){
				stage.addEventListener(MouseEvent.MOUSE_UP, onMouseRelease);
				_highlit = false;
				_over = true;
				_down = true;
				invalidate();
			}
		}
		protected function onClick(e:MouseEvent):void{
			if(!enabled){
				e.stopImmediatePropagation();
			}
			if(this.autoToggleSelect)toggle();
			invalidate();
		}
		protected function onMouseRelease(e:MouseEvent):void{
			if (stage) {
				stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseRelease);
			}
			if(this.mouseDown){
				_highlit = false;
				_down = false;
				invalidate();
			}
		}
		protected function onSetFocus(e:FocusEvent):void{
			//highlit = true;
		}
		protected function onKillFocus(e:FocusEvent):void{
			//highlit = false;
		}
		protected function toggle():void {
			this.selected = !this.selected;
			dispatchEvent(new ControlEvent(ControlEvent.BUTTON_TOGGLE));
			dispatchEvent(new ControlEvent(ControlEvent.USER_BUTTON_TOGGLE));
			invalidate();
		}
		override protected function draw():void{
			if(!enabled){
				showStateList([DISABLED_STATE,UP_STATE]);
			}else if(selected){
				if(_highlit)showStateList([SELECTED_HIGHLIGHT_STATE,SELECTED_OVER_STATE,SELECTED_UP_STATE,UP_STATE]);
				else if(this.mouseDown)showStateList([SELECTED_DOWN_STATE,SELECTED_OVER_STATE,SELECTED_UP_STATE,DOWN_STATE,UP_STATE]);
				else if(this.mouseOver)showStateList([SELECTED_OVER_STATE,SELECTED_UP_STATE,OVER_STATE,UP_STATE]);
				else showStateList([SELECTED_UP_STATE,UP_STATE]);
			}else{
				if(_highlit)showStateList([HIGHLIGHT_STATE,OVER_STATE,UP_STATE]);
				else if(this.mouseDown)showStateList([DOWN_STATE,OVER_STATE,UP_STATE]);
				else if(this.mouseOver)showStateList([OVER_STATE,UP_STATE]);
				else showStateList([UP_STATE]);
			}
		}
	}
}