package au.com.thefarmdigital.display.form
{
	import au.com.thefarmdigital.display.controls.Control;
	import au.com.thefarmdigital.display.form.events.FormEvent;
	import au.com.thefarmdigital.validation.IValidator;
	import au.com.thefarmdigital.validation.ValidationEvent;
	import au.com.thefarmdigital.validation.ValidationResult;
	import au.com.thefarmdigital.validation.ValidatorGroup;
	
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	import org.farmcode.core.DelayedCall;
	
	[Event(name="submit",type="au.com.thefarmdigital.display.form.events.FormEvent")]
	[Event(name="invalid",type="au.com.thefarmdigital.display.form.events.FormEvent")]
	/**
	 * The Form class groups controls together to simplify validation and tabbing.
	 * It also provides the ability to add a submit and a clear button to the form.
	 */
	public class Form extends ValidatorGroup implements IForm
	{
		// Button Types
		public static const BUTTON_SUBMIT:String = "buttonSubmit";
		public static const BUTTON_CLEAR:String = "buttonClear";
		
		public function get active():Boolean{
			return _active;
		}
		
		public function set focusToFirstError(focus: Boolean): void {
			this._focusToFirstError = focus;
		}
		
		public function get focusToFirstError(): Boolean {
			return this._focusToFirstError;
		}
		
		public function set highlightInvalidFields(highlightInvalidFields: Boolean): void{
			if (this._highlightInvalidFields != highlightInvalidFields){
				this._highlightInvalidFields = highlightInvalidFields;
			}
		}
		public function get highlightInvalidFields(): Boolean{
			return this._highlightInvalidFields;
		}
		
		protected var _controls:Array = [];
		protected var _buttons:Array = [];
		protected var _active:Boolean = false;
		protected var _inactiveCall:DelayedCall;
		protected var _focusToFirstError: Boolean;
		protected var _highlightInvalidFields: Boolean;
		protected var _enabled: Boolean = true;
		protected var _visible: Boolean = true;
		
		public function Form(controls:Array=null){
			this._focusToFirstError = true;
			this._highlightInvalidFields = true;
			this.enabled = true;
			var formIndex:Number = 0;
			if (controls) {
				var length:int = controls.length;
				for(var i:int=0; i<length; ++i){
					var control:Control = controls[i];
					if(control.formIndex==-1)control.formIndex = formIndex;
					formIndex = control.formIndex+1;
					addControl(control);
				}
			}
		}
		
		public function set visible(visible: Boolean): void
		{
			if (visible != this._visible)
			{
				this._visible = visible;
				for (var i: uint = 0; i < this._controls.length; ++i)
				{
					var control: Control = this._controls[i];
					this.setControlVisible(control, this._visible);
				}
				for (var j: uint = 0; j < this._buttons.length; ++j)
				{
					var bPair: ButtonPair = this._buttons[j];
					var button: InteractiveObject = bPair.button;
					this.setControlVisible(button, this._visible);
				}
			}
		}
		public function get visible(): Boolean
		{
			return this._visible;
		}
		
		protected function setControlVisible(control: DisplayObject, visible: Boolean): void
		{
			control.visible = visible;
		}
		
		public function set enabled(enabled: Boolean): void
		{
			if (enabled != this._enabled)
			{
				this._enabled = enabled;
				
				for (var i: uint = 0; i < this._controls.length; ++i)
				{
					var control: Control = this._controls[i];
					this.setControlEnabled(control, this._enabled);
				}
				for (var j: uint = 0; j < this._buttons.length; ++j)
				{
					var bPair: ButtonPair = this._buttons[j];
					var button: InteractiveObject = bPair.button;
					this.setControlEnabled(button, this._enabled);
				}
			}
		}
		public function get enabled(): Boolean
		{
			return this._enabled;
		}
		
		protected function setControlEnabled(display: DisplayObject, enabled: Boolean): void
		{
			if (display is Control)
			{
				var control: Control = display as Control;
				control.mouseEnabled = enabled;
			}
			else if (display is InteractiveObject)
			{
				var intDisplay: InteractiveObject = display as InteractiveObject;
				intDisplay.mouseEnabled = enabled;
			}
		}
		
		public function addControl(control:Control, validator:IValidator=null): void
		{
			if (this._controls.indexOf(control) < 0)
			{
				_controls.push(control);
				control.tabIndex = -1;
				if (control.formIndex == -1) {
					control.formIndex = this.getLastFormIndex() + 1;
				}
				control.addEventListener(FocusEvent.FOCUS_IN,onFocusIn);
				control.addEventListener(FocusEvent.FOCUS_OUT,onFocusOut);
				if(_active)assignTabIndices();
				this.setControlEnabled(control, this._enabled);
			}
			if(validator){
				validator.subject = control;
				addValidator(validator);
			}
		}
		
		protected function getLastFormIndex(): Number {
			var lastIndex: Number = 0;
			var length:int = this._controls.length;
			for(var i:int=0; i<length; ++i){
				var control:Control = this._controls[i] as Control;
				if(control.formIndex > lastIndex) {
					lastIndex = control.formIndex;
				}
			}
			return lastIndex;
		}
		public function addErrorMessage(errorType:String, message:String):void{
			if(!_readableMessages){
				_readableMessages = new Dictionary();
			}
			_readableMessages[errorType] = message;
		}
		public function removeErrorMessage(errorType:String):void{
			if(_readableMessages){
				delete _readableMessages[errorType];
			}
		}
		public function addSubmitButton(button: InteractiveObject): void{
			this.addButton(button, Form.BUTTON_SUBMIT);
		}
		public function addClearButton(button: InteractiveObject): void{
			this.addButton(button, Form.BUTTON_CLEAR);
		}
		public function addButton(button:InteractiveObject, type:String = null):void{
			button.tabIndex = -1;
			_buttons.push(new ButtonPair(type,button));
			button.addEventListener(MouseEvent.CLICK,onButtonClick);
			button.addEventListener(FocusEvent.FOCUS_IN,onFocusIn);
			button.addEventListener(FocusEvent.FOCUS_OUT,onFocusOut);
			if(_active)assignTabIndices();
			this.setControlEnabled(button, this._enabled);
		}
		public function removeControl(control:Control):void{
			var controlIndex: int = this._controls.indexOf(control);
			if (controlIndex >= 0)
			{
				this._controls.splice(controlIndex, 1);
				if(_active)assignTabIndices();
			}
		}
		
		override protected function _validate():ValidationResult{
			var valid:Boolean = true;
			var invalidControls: Array = new Array();
			var firstFound:Boolean = false;
			var ret:ValidationResult = new ValidationResult();
			_validationResult.isComplete = true;
			_validationResult.errors = [];
			
			for(var i:* in _validators){
				var validator:IValidator = (i as IValidator);
				var result:ValidationResult = (_validators[i] as ValidationResult);
				if(!result){
					result = validator.validate();
					if(result.isComplete){
						_validators[i] = result;
						_validationResult.errors = _validationResult.errors.concat(result.errors);
						var control:Control = (validator.subject as Control);
						if(control && _controls.indexOf(control)!=-1){
							if(!result.isValid){
								if(_focusToFirstError && !firstFound){
									firstFound = true;
									control.setFocus();
								}
							}
						}
					}else if(!_liveValidation){
						_validationResult.isComplete = false;
						validator.addEventListener(ValidationEvent.VALIDATION_COMPLETE, onValidationComplete);
					}
				}
			}
			return _validationResult;
		}
		
		public function focusOnControl(control: Control): void
		{
			if (this.hasControl(control))
			{
				control.setFocus();
				control.highlit = true;
			}
		}
		
		public function hasControl(control: Control): Boolean
		{
			return this._controls.indexOf(control) >= 0;
		}		
		
		public function clear():void{
			var length:int = _controls.length;
			for(var i:int=0; i<length; ++i){
				var control:Control= _controls[i] as Control;
				control.clear();
			}
		}
		protected function onButtonClick(e:MouseEvent):void{
			var index:Number = getButtonIndex(e.target as InteractiveObject);
			if(!isNaN(index)){
				var type:String = (_buttons[index] as ButtonPair).type;
				if(type==BUTTON_SUBMIT){
					if(validate().isValid){
						dispatchEvent(new FormEvent(FormEvent.SUBMIT));
					}else{
						var event:FormEvent = new FormEvent(FormEvent.INVALID);
						event.validationResult = _validationResult;
						dispatchEvent(event);
					}
				}else if(type==BUTTON_CLEAR){
					clear();
				}
			}
		}
		protected function onFocusIn(e:FocusEvent):void{
			if(_inactiveCall){
				_inactiveCall.clear();
				_inactiveCall = null;
			}
			if(!_active){
				_active = true;
				assignTabIndices();
			}
		}
		protected function onFocusOut(e:FocusEvent):void{
			if(_active){
				_inactiveCall = new DelayedCall(doFocusOut,1,false);
				_inactiveCall.begin();
			}
		}
		protected function doFocusOut():void{
			if(_active){
				_active = false;
				removeTabIndices();
			}
		}
		protected function assignTabIndices():void{
			var order:Array = _controls.slice();
			order.sortOn("formIndex",Array.NUMERIC);
			var length:int = order.length;
			for(var i:int=0; i<length; ++i){
				var control:Control = order[i] as Control;
				control.tabIndex = i+1;
			}
			order = _buttons.slice();
			length = order.length;
			for(i=0; i<length; ++i){
				var buttonPair:ButtonPair = order[i];
				buttonPair.button.tabIndex = (i+_controls.length+1);
			}
		}
		protected function removeTabIndices():void{
			var length:int = _controls.length;
			for(var i:int=0; i<length; ++i){
				var control:Control = _controls[i] as Control;
				control.tabIndex = -1;
			}
			length = _buttons.length;
			for(i=0; i<length; ++i){
				var buttonPair:ButtonPair = _buttons[i];
				buttonPair.button.tabIndex = -1;
			}
		}
		protected function getButtonIndex(button:InteractiveObject):Number{
			var length:int = _buttons.length;
			for(var i:int=0; i<length; ++i){
				if(button==(_buttons[i] as ButtonPair).button)return i;
			}
			return NaN;
		}
	}
}

import flash.display.InteractiveObject;
import au.com.thefarmdigital.display.controls.Control;
	
class ButtonPair
{
	public var type:String;
	public var button:InteractiveObject;
	public function ButtonPair(type:String,button:InteractiveObject){
		this.type = type;
		this.button = button;
	}
}