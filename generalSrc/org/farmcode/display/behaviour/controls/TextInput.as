package org.farmcode.display.behaviour.controls
{
	import au.com.thefarmdigital.validation.ValidationEvent;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.data.dataTypes.IStringConsumer;
	import org.farmcode.data.dataTypes.IStringProvider;
	import org.farmcode.display.tabFocus.ITabFocusable;
	import org.farmcode.display.tabFocus.InteractiveObjectFocusWrapper;
	import org.farmcode.display.utils.positionDisplayByBounds;
	
	//TODO: combine duplicated functionality from Textlabel
	[Event(name="change",type="flash.events.Event")]
	public class TextInput extends Control
	{
		private static const TEXT_FIELD_GUTTER:Number = 1;
		
		
		public function get data():*{
			return _data;
		}
		public function set data(value:*):void{
			if(_data!=value){
				if(_stringProvider){
					_stringProvider.stringValueChanged.removeHandler(onProviderChanged);
				}
				_data = value;
				_stringConsumer = (value as IStringConsumer);
				_stringProvider = (value as IStringProvider);
				if(_stringProvider){
					_stringProvider.stringValueChanged.addHandler(onProviderChanged);
				}
				syncFieldToData();
				
			}
		}
		public function get text():*{
			return _stringData;
		}
		public function get prompt():String{
			return _prompt;
		}
		public function set prompt(value:String):void{
			if(_prompt!=value){
				_prompt = value;
				applyPrompt();
			}
		}
		public function get textFormat():TextFormat{
			return _textFormat;
		}
		public function set textFormat(value:TextFormat):void{
			if(_textFormat!=value){
				_textFormat = value;
				applyFormat();
			}
		}
		public function get paddingTop():Number{
			return _paddingTop;
		}
		public function set paddingTop(value:Number):void{
			if(_paddingTop!=value){
				_paddingTop = value;
				invalidate();
			}
		}
		public function get paddingLeft():Number{
			return _paddingLeft;
		}
		public function set paddingLeft(value:Number):void{
			if(_paddingLeft!=value){
				_paddingLeft = value;
				invalidate();
			}
		}
		public function get paddingRight():Number{
			return _paddingRight;
		}
		public function set paddingRight(value:Number):void{
			if(_paddingRight!=value){
				_paddingRight = value;
				invalidate();
			}
		}
		public function get paddingBottom():Number{
			return _paddingBottom;
		}
		public function set paddingBottom(value:Number):void{
			if(_paddingBottom!=value){
				_paddingBottom = value;
				invalidate();
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
			checkIsBound();
			return _tabFocusable;
		}
		override public function set asset(value:DisplayObject):void{
			if(!_stringProvider)_data = null;
			super.asset = value;
		}
		
		/**
		 * handler(from:TextInput)
		 */
		public function get enterKeyPressed():IAct{
			if(!_enterKeyPressed)_enterKeyPressed = new Act();
			return _enterKeyPressed;
		}
		
		protected var _enterKeyPressed:Act;
		
		protected var _data:*;
		protected var _stringData:String;
		protected var _stringConsumer:IStringConsumer;
		protected var _stringProvider:IStringProvider;
		protected var _textField:TextField;
		protected var _unselectedState:DisplayObject;
		protected var _tabFocusable:InteractiveObjectFocusWrapper;
		
		protected var _showingPrompt:Boolean;
		protected var _focused:Boolean;
		protected var _prompt:String;
		protected var _assumedPrompt:String;
		
		protected var _restrict:String;
		protected var _maxChars:int = 0;
		
		protected var _textFormat:TextFormat;
		protected var _assumedTextFormat:TextFormat;
		
		protected var _paddingTop:Number;
		protected var _assumedPaddingTop:Number;
		protected var _paddingLeft:Number;
		protected var _assumedPaddingLeft:Number;
		protected var _paddingBottom:Number;
		protected var _assumedPaddingBottom:Number;
		protected var _paddingRight:Number;
		protected var _assumedPaddingRight:Number;
		
		public function TextInput(asset:DisplayObject=null){
			super(asset);
		}
		protected function onProviderChanged(from:IStringProvider):void{
			syncFieldToData();
		}
		override protected function bindToAsset() : void{
			_textField = containerAsset.getChildByName("textField") as TextField;
			_textField.addEventListener(Event.CHANGE, onTextChange);
			_textField.addEventListener(FocusEvent.FOCUS_IN, onFocusIn);
			_textField.addEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
			_textField.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			_textField.type = TextFieldType.INPUT;
			_tabFocusable = new InteractiveObjectFocusWrapper(_textField);
			
			_unselectedState = containerAsset.getChildByName("unselectedState");
			_assumedTextFormat = _textField.defaultTextFormat;
			_assumedPrompt = _textField.text;
			_showingPrompt = true;
			
			if(_unselectedState){
				_assumedPaddingTop = (_textField.y+TEXT_FIELD_GUTTER)-_unselectedState.y;
				_assumedPaddingLeft = (_textField.x+TEXT_FIELD_GUTTER)-_unselectedState.x;
				_assumedPaddingBottom = (_unselectedState.y+_unselectedState.height)-(_textField.y+_textField.height-TEXT_FIELD_GUTTER);
				_assumedPaddingRight = (_unselectedState.x+_unselectedState.width)-(_textField.x+_textField.width-TEXT_FIELD_GUTTER);
			}else{
				_assumedPaddingTop = TEXT_FIELD_GUTTER;
				_assumedPaddingLeft = TEXT_FIELD_GUTTER;
				_assumedPaddingBottom = TEXT_FIELD_GUTTER;
				_assumedPaddingRight = TEXT_FIELD_GUTTER;
			}
			
			applyFormat();
			syncFieldToData();
			applyPrompt();
		}
		protected function onFocusIn(e:Event) : void{
			_focused = true;
			if(_showingPrompt){
				_textField.text = "";
				_showingPrompt = false;
				applyPrompt();
			}
		}
		protected function onFocusOut(e:Event) : void{
			_focused = false;
			if(_textField.text==""){
				_showingPrompt = true;
				applyPrompt();
			}
		}
		protected function onKeyUp(e:KeyboardEvent) : void{
			if(e.charCode==Keyboard.ENTER && _enterKeyPressed){
				_enterKeyPressed.perform(this);
			}
		}
		protected function onTextChange(e:Event) : void{
			dispatchEvent(e);
			dispatchEvent(new ValidationEvent(ValidationEvent.VALIDATION_VALUE_CHANGED));
			syncDataToField();
		}
		override protected function unbindFromAsset() : void{
			_tabFocusable = null;
			_focused = _showingPrompt = false;
			_textField.removeEventListener(Event.CHANGE, onTextChange);
			_textField.removeEventListener(FocusEvent.FOCUS_IN, onFocusIn);
			_textField.removeEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
			_textField = null; 
			_assumedTextFormat = null;
			_assumedPrompt = null;
		}
		protected function applyFormat() : void{
			if(_textField){
				var format:TextFormat = getValueOrAssumed(_textFormat,_assumedTextFormat);
				if(format){
					_textField.defaultTextFormat = format;
					_textField.setTextFormat(format);
				}
			}
		}
		protected function applyPrompt() : void{
			if(_textField){
				if(_showingPrompt){
					_textField.restrict = null;
					_textField.maxChars = 0;
					_textField.text = getValueOrAssumed(_prompt,_assumedPrompt,"");
				}else{
					_textField.maxChars = _maxChars;
					_textField.restrict = _restrict;
				}
			}
		}
		override protected function draw() : void{
			_measureFlag.validate();
			var pos:Rectangle = displayPosition;
			asset.x = pos.x;
			asset.y = pos.y;
			if(_unselectedState)positionDisplayByBounds(_unselectedState,0,0,pos.width,pos.height);
			var pTop:Number = getValueOrAssumed(_paddingTop,_assumedPaddingTop,0);
			var pLeft:Number = getValueOrAssumed(_paddingLeft,_assumedPaddingLeft,0);
			var pBottom:Number = getValueOrAssumed(_paddingBottom,_assumedPaddingBottom,0);
			var pRight:Number = getValueOrAssumed(_paddingRight,_assumedPaddingRight,0);
			positionDisplayByBounds(_textField,pLeft-TEXT_FIELD_GUTTER,pTop-TEXT_FIELD_GUTTER,
												pos.width-pLeft-pRight+TEXT_FIELD_GUTTER*2,pos.height-pTop-pBottom+TEXT_FIELD_GUTTER*2);
			
		}
		protected function getValueOrAssumed(value:*, assumedValue:*, defaultValue:*=null) : *{
			if(value!=null && (!isNaN(value) || !(value is Number))){
				return value;
			}else if(assumedValue!=null && (!isNaN(assumedValue) || !(assumedValue is Number))){
				return assumedValue;
			}
			return defaultValue;
		}
		override public function getValidationValue(validityKey:String=null):*{
			return _stringData;
		}
		override public function setValidationValue(value:*, validityKey:String=null):void{
			_stringData = value;
			if(!_stringData)_stringData = "";
			fillField();
			fillData();
		}
		protected function syncFieldToData():void{
			if(_textField){
				var newStr:String;
				if(_stringProvider){
					newStr = _stringProvider.stringValue;
				}else{
					newStr = _data as String;
				}
				if(!newStr)newStr = "";
				if(_stringData!=newStr){
					_stringData = newStr;
					fillField();
				}
			}
		}
		protected function syncDataToField():void{
			if(_textField){
				var newStr:String;
				if(_showingPrompt){
					newStr = "";
				}else if(_textField){
					newStr = _textField.text;
				}
				if(_stringData!=newStr){
					_stringData = newStr;
					fillData();
				}
			}
		}
		protected function fillField():void{
			if(_stringData.length || _focused){
				_textField.text = _stringData;
				_showingPrompt = false;
			}else if(!_showingPrompt){
				_showingPrompt = true;
				applyPrompt();
			}
		}
		protected function fillData():void{
			if(_stringConsumer){
				_stringConsumer.stringValue = _stringData;
			}else{
				_data = _stringData;
			}
		}
	}
}