package org.tbyrne.display.controls
{
	import flash.events.Event;
	import flash.text.TextFieldType;
	import flash.ui.Keyboard;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.data.controls.IControlData;
	import org.tbyrne.data.dataTypes.IStringConsumer;
	import org.tbyrne.data.dataTypes.IStringProvider;
	import org.tbyrne.data.dataTypes.IValueConsumer;
	import org.tbyrne.display.DisplayNamespace;
	import org.tbyrne.display.actInfo.IKeyActInfo;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
	import org.tbyrne.display.assets.nativeTypes.IInteractiveObject;
	import org.tbyrne.display.assets.nativeTypes.ITextField;
	import org.tbyrne.display.assets.states.StateDef;
	import org.tbyrne.display.tabFocus.ITabFocusable;
	import org.tbyrne.display.tabFocus.InteractiveAssetFocusWrapper;
	
	use namespace DisplayNamespace;
	
	public class TextInput extends TextLabel
	{
		DisplayNamespace static const STATE_FOCUSED:String = "focused";
		DisplayNamespace static const STATE_UNFOCUSED:String = "unfocused";
		
		
		public function get prompt():String{
			return _prompt;
		}
		public function set prompt(value:String):void{
			if(_prompt!=value){
				_prompt = value;
				applyPrompt();
			}
		}
		public function get restrict():String{
			return _restrict;
		}
		public function set restrict(value:String):void{
			if(_restrict!=value){
				_restrict = value;
				applyPrompt();
			}
		}
		public function get displayAsPassword():Boolean{
			return _displayAsPassword;
		}
		public function set displayAsPassword(value:Boolean):void{
			if(_displayAsPassword!=value){
				_displayAsPassword = value;
				applyPrompt();
			}
		}
		public function get maxChars():int{
			return _maxChars;
		}
		public function set maxChars(value:int):void{
			if(_maxChars!=value){
				_maxChars = value;
				applyPrompt();
			}
		}
		
		public function get focused(): Boolean{
			return this._focused;
		}
		public function get tabFocusable(): ITabFocusable{
			attemptInit();
			return _tabFocusable;
		}
		override public function set asset(value:IDisplayObject):void{
			if(!_stringProvider)_stringData = null;
			super.asset = value;
		}
		/**
		 * handler(from:TextInput)
		 */
		public function get enterKeyPressed():IAct{
			if(!_enterKeyPressed)_enterKeyPressed = new Act();
			return _enterKeyPressed;
		}
		/**
		 * handler(from:TextInput)
		 */
		public function get focusedChanged():IAct{
			if(!_focusedChanged)_focusedChanged = new Act();
			return _focusedChanged;
		}
		
		override public function set active(value:Boolean):void{
			if(super.active!=value){
				if(_labelField){
					_labelField.type = (_active?TextFieldType.INPUT:TextFieldType.DYNAMIC);
					_labelField.selectable = _active;
				}
				super.active = value;
			}
		}
		
		protected var _focusedChanged:Act;
		protected var _enterKeyPressed:Act;
		
		protected var _showingPrompt:Boolean;
		protected var _focused:Boolean;
		protected var _prompt:String;
		protected var _assumedPrompt:String;
		protected var _restrict:String;
		protected var _maxChars:int = 0;
		protected var _displayAsPassword:Boolean;
		protected var _tabFocusable:InteractiveAssetFocusWrapper;
		
		protected var _stringConsumer:IStringConsumer;
		
		protected var _focusedState:StateDef = new StateDef([STATE_UNFOCUSED,STATE_FOCUSED],0);

		private var _ignoreChanges:Boolean;

		
		public function TextInput(asset:IDisplayObject=null){
			super(asset);
		}
		override protected function init() : void{
			super.init();
			_tabFocusable = new InteractiveAssetFocusWrapper();
		}
		override protected function bindTextField():void{
			super.bindTextField();
			_assumedPrompt = _labelField.text;
			setText("");
			_labelField.change.addHandler(onTextChange);
			_labelField.focusIn.addHandler(onFocusIn);
			_labelField.focusOut.addHandler(onFocusOut);
			_labelField.keyUp.addHandler(onKeyUp);
			
			//_labelField.type = TextFieldType.INPUT;
			_tabFocusable.interactiveAsset = _labelField;
			
			
			_labelField.type = (_active?TextFieldType.INPUT:TextFieldType.DYNAMIC);
			_labelField.selectable = _active;
		}
		protected function onFocusIn(from:IInteractiveObject) : void{
			if(!_focused){
				_focusedState.selection = 1;
				_focused = true;
				if(_showingPrompt){
					setText("");
					_showingPrompt = false;
					applyPrompt();
				}
				if(_focusedChanged)_focusedChanged.perform(this);
			}
		}
		protected function onFocusOut(from:IInteractiveObject) : void{
			if(_focused){
				_focusedState.selection = 0;
				_focused = false;
				if(_labelField.text==""){
					_showingPrompt = true;
					applyPrompt();
				}
				if(_focusedChanged)_focusedChanged.perform(this);
			}
		}
		protected function onKeyUp(from:IInteractiveObject, info:IKeyActInfo) : void{
			if(info.charCode==Keyboard.ENTER && _enterKeyPressed){
				_enterKeyPressed.perform(this);
			}
		}
		protected function onTextChange(from:ITextField) : void{
			if(!_ignoreChanges)syncDataToField();
		}
		override protected function unbindFromAsset() : void{
			_tabFocusable.interactiveAsset = null;
			if(_focused){
				_focusedState.selection = 0;
				_focused = false;
				if(_focusedChanged)_focusedChanged.perform(this);
			}
			_showingPrompt = false;
			
			setText(_assumedPrompt);
			_labelField.change.removeHandler(onTextChange);
			_labelField.focusIn.removeHandler(onFocusIn);
			_labelField.focusOut.removeHandler(onFocusOut);
			_labelField.keyUp.removeHandler(onKeyUp);
			
			_assumedPrompt = null;
			super.unbindFromAsset();
		}
		override protected function fillField():void{
			if(_stringData.length || _focused){
				setText(_stringData);
				_showingPrompt = false;
			}else if(!_showingPrompt && _labelField){
				_showingPrompt = true;
				applyPrompt();
			}
		}
		protected function setText(value:String):void{
			_ignoreChanges = true;
			_labelField.text = value;
			_ignoreChanges = false;
		}
		protected function applyPrompt() : void{
			if(_labelField){
				if(_showingPrompt){
					_labelField.restrict = null;
					_labelField.maxChars = 0;
					setText(getValueOrAssumed(_prompt,_assumedPrompt,""));
					_labelField.displayAsPassword = false;
				}else{
					_labelField.maxChars = _maxChars;
					_labelField.restrict = _restrict;
					_labelField.displayAsPassword = _displayAsPassword;
				}
			}
		}
		protected function syncDataToField():void{
			if(_labelField){
				var newStr:String;
				if(_showingPrompt){
					newStr = "";
				}else if(_labelField){
					newStr = _labelField.text;
				}
				if(_stringData!=newStr){
					_stringData = newStr;
					fillData();
				}
			}
		}
		protected function fillData():void{
			if(_stringConsumer){
				_stringConsumer.stringValue = _stringData;
			}
		}
		override protected function getMeasurementText():String{
			return getValueOrAssumed(_prompt,_assumedPrompt,"");
		}
		override protected function fillStateList(fill:Array):Array{
			fill = super.fillStateList(fill);
			fill.push(_focusedState);
			return fill;
		}
		
		override protected function clearData():void{
			super.clearData();
			if(_stringConsumer){
				_stringConsumer = null;
			}
		}
		
		override protected function assessData():void{
			super.assessData();
			if(_stringProvider){
				_stringConsumer = (_stringProvider as IStringConsumer);
			}
		}
		override protected function getLabelProvider(data:IControlData):IStringProvider{
			return data.stringValue;
		}
	}
}