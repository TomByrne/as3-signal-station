package org.farmcode.display.controls
{
	import flash.display.TextFieldGutter;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Rectangle;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.data.dataTypes.IStringConsumer;
	import org.farmcode.data.dataTypes.IStringProvider;
	import org.farmcode.display.DisplayNamespace;
	import org.farmcode.display.assets.assetTypes.IDisplayAsset;
	import org.farmcode.display.assets.assetTypes.IInteractiveObjectAsset;
	import org.farmcode.display.assets.assetTypes.ITextFieldAsset;
	import org.farmcode.display.assets.states.StateDef;
	import org.farmcode.display.tabFocus.ITabFocusable;
	import org.farmcode.display.tabFocus.InteractiveAssetFocusWrapper;
	
	use namespace DisplayNamespace;
	
	
	//TODO: combine duplicated functionality from Textlabel
	public class TextInput_old extends Control
	{
		
		DisplayNamespace static const TEXT_FIELD_CHILD:String = "textField";
		DisplayNamespace static const INPUT_BACKING_CHILD:String = "inputBacking";
		
		
		DisplayNamespace static const STATE_FOCUSED:String = "focused";
		DisplayNamespace static const STATE_UNFOCUSED:String = "unfocused";
		
		
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
		override public function set asset(value:IDisplayAsset):void{
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
		/**
		 * handler(from:TextInput)
		 */
		public function get focusedChanged():IAct{
			if(!_focusedChanged)_focusedChanged = new Act();
			return _focusedChanged;
		}
		
		override public function set active(value:Boolean):void{
			if(super.active!=value){
				if(_inputField){
					_inputField.type = (_active?TextFieldType.INPUT:TextFieldType.DYNAMIC);
					_inputField.selectable = _active;
				}
				super.active = value;
			}
		}
		
		protected var _focusedChanged:Act;
		protected var _enterKeyPressed:Act;
		
		protected var _data:*;
		protected var _stringData:String;
		protected var _stringConsumer:IStringConsumer;
		protected var _stringProvider:IStringProvider;
		protected var _inputField:ITextFieldAsset;
		protected var _inputBacking:IDisplayAsset;
		protected var _tabFocusable:InteractiveAssetFocusWrapper;
		
		protected var _showingPrompt:Boolean;
		protected var _focused:Boolean;
		protected var _prompt:String;
		protected var _assumedPrompt:String;
		
		protected var _focusedState:StateDef = new StateDef([STATE_UNFOCUSED,STATE_FOCUSED],0);
		
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
		
		public function TextInput_old(asset:IDisplayAsset=null){
			super(asset);
		}
		protected function onProviderChanged(from:IStringProvider):void{
			syncFieldToData();
		}
		override protected function bindToAsset() : void{
			super.bindToAsset();
			_inputField = _containerAsset.takeAssetByName(TEXT_FIELD_CHILD,ITextFieldAsset);
			_inputField.change.addHandler(onTextChange);
			_inputField.focusIn.addHandler(onFocusIn);
			_inputField.focusOut.addHandler(onFocusOut);
			_inputField.keyUp.addHandler(onKeyUp);
			
			_inputField.type = TextFieldType.INPUT;
			_tabFocusable = new InteractiveAssetFocusWrapper(_inputField);
			
			_inputBacking = _containerAsset.takeAssetByName(INPUT_BACKING_CHILD, IDisplayAsset,true);
			_assumedTextFormat = _inputField.defaultTextFormat;
			_assumedPrompt = _inputField.text;
			_showingPrompt = true;
			
			
			if(_inputBacking){
				// some fonts have slightly different gutters, this will help us work it out.
				
				var operableHeight:Number;
				if(_inputField.height<_inputField.textHeight+TextFieldGutter.TEXT_FIELD_GUTTER*2){
					operableHeight = _inputField.textHeight;
				}else{
					operableHeight = _inputField.height-TextFieldGutter.TEXT_FIELD_GUTTER*2;
				}
				
				var operableWidth:Number;
				if(_inputField.width<_inputField.textWidth+TextFieldGutter.TEXT_FIELD_GUTTER*2){
					operableWidth = _inputField.textWidth;
				}else{
					operableWidth = _inputField.width-TextFieldGutter.TEXT_FIELD_GUTTER*2;
				}
				
				_assumedPaddingTop = (_inputField.y+TextFieldGutter.TEXT_FIELD_GUTTER)-_inputBacking.y;
				_assumedPaddingLeft = (_inputField.x+TextFieldGutter.TEXT_FIELD_GUTTER)-_inputBacking.x;
				_assumedPaddingBottom = (_inputBacking.y+_inputBacking.height)-(_inputField.y+TextFieldGutter.TEXT_FIELD_GUTTER+operableHeight);
				_assumedPaddingRight = (_inputBacking.x+_inputBacking.width)-(_inputField.x+TextFieldGutter.TEXT_FIELD_GUTTER+operableWidth);
			}else{
				_assumedPaddingTop = 0;
				_assumedPaddingLeft = 0;
				_assumedPaddingBottom = 0;
				_assumedPaddingRight = 0;
			}
			
			_inputField.type = (_active?TextFieldType.INPUT:TextFieldType.DYNAMIC);
			_inputField.selectable = _active;
			
			applyFormat();
			syncFieldToData();
			applyPrompt();
		}
		protected function onFocusIn(e:Event, from:IInteractiveObjectAsset) : void{
			if(!_focused){
				_focusedState.selection = 1;
				_focused = true;
				if(_showingPrompt){
					_inputField.text = "";
					_showingPrompt = false;
					applyPrompt();
				}
				if(_focusedChanged)_focusedChanged.perform(this);
			}
		}
		protected function onFocusOut(e:Event, from:IInteractiveObjectAsset) : void{
			if(_focused){
				_focusedState.selection = 0;
				_focused = false;
				if(_inputField.text==""){
					_showingPrompt = true;
					applyPrompt();
				}
				if(_focusedChanged)_focusedChanged.perform(this);
			}
		}
		protected function onKeyUp(e:KeyboardEvent, from:IInteractiveObjectAsset) : void{
			if(e.charCode==Keyboard.ENTER && _enterKeyPressed){
				_enterKeyPressed.perform(this);
			}
		}
		protected function onTextChange(e:Event, from:ITextFieldAsset) : void{
			syncDataToField();
		}
		override protected function unbindFromAsset() : void{
			_tabFocusable = null;
			if(_focused){
				_focusedState.selection = 0;
				_focused = false;
				if(_focusedChanged)_focusedChanged.perform(this);
			}
			_showingPrompt = false;
			_stringData = null;
			
			if(_inputBacking){
				_containerAsset.returnAsset(_inputBacking);
				_inputBacking = null;
			}
			
			_inputField.change.removeHandler(onTextChange);
			_inputField.focusIn.removeHandler(onFocusIn);
			_inputField.focusOut.removeHandler(onFocusOut);
			_inputField.keyUp.removeHandler(onKeyUp);
			_containerAsset.returnAsset(_inputField);
			_inputField = null;
			
			_assumedTextFormat = null;
			_assumedPrompt = null;
			super.unbindFromAsset();
		}
		protected function applyFormat() : void{
			if(_inputField){
				var format:TextFormat = getValueOrAssumed(_textFormat,_assumedTextFormat);
				if(format){
					_inputField.defaultTextFormat = format;
					_inputField.setTextFormat(format);
				}
			}
		}
		protected function applyPrompt() : void{
			if(_inputField){
				if(_showingPrompt){
					_inputField.restrict = null;
					_inputField.maxChars = 0;
					_inputField.text = getValueOrAssumed(_prompt,_assumedPrompt,"");
				}else{
					_inputField.maxChars = _maxChars;
					_inputField.restrict = _restrict;
				}
			}
		}
		override protected function draw() : void{
			_measureFlag.validate();
			var pos:Rectangle = displayPosition;
			asset.setPosition(pos.x,pos.y);
			if(_inputBacking){
				_inputBacking.setSizeAndPos(0,0,pos.width,pos.height);
			}
			var pTop:Number = getValueOrAssumed(_paddingTop,_assumedPaddingTop,0);
			var pLeft:Number = getValueOrAssumed(_paddingLeft,_assumedPaddingLeft,0);
			var pBottom:Number = getValueOrAssumed(_paddingBottom,_assumedPaddingBottom,0);
			var pRight:Number = getValueOrAssumed(_paddingRight,_assumedPaddingRight,0);
			
			_inputField.setSizeAndPos(pLeft-TextFieldGutter.TEXT_FIELD_GUTTER,
								pTop-TextFieldGutter.TEXT_FIELD_GUTTER,
								pos.width-pLeft-pRight+TextFieldGutter.TEXT_FIELD_GUTTER*2,
								pos.height-pTop-pBottom+TextFieldGutter.TEXT_FIELD_GUTTER*2);
			
			
		}
		protected function getValueOrAssumed(value:*, assumedValue:*, defaultValue:*=null) : *{
			if(value!=null && (!isNaN(value) || !(value is Number))){
				return value;
			}else if(assumedValue!=null && (!isNaN(assumedValue) || !(assumedValue is Number))){
				return assumedValue;
			}
			return defaultValue;
		}
		protected function syncFieldToData():void{
			if(_inputField){
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
			if(_inputField){
				var newStr:String;
				if(_showingPrompt){
					newStr = "";
				}else if(_inputField){
					newStr = _inputField.text;
				}
				if(_stringData!=newStr){
					_stringData = newStr;
					fillData();
				}
			}
		}
		protected function fillField():void{
			if(_stringData.length || _focused){
				_inputField.text = _stringData;
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
		override protected function fillStateList(fill:Array):Array{
			fill = super.fillStateList(fill);
			fill.push(_focusedState);
			return fill;
		}
	}
}