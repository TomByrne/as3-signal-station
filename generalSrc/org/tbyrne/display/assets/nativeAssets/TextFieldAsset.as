package org.tbyrne.display.assets.nativeAssets
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.TextFieldGutter;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.NativeAct;
	import org.tbyrne.debug.logging.Log;
	import org.tbyrne.display.assets.assetTypes.IDisplayAsset;
	import org.tbyrne.display.assets.assetTypes.ITextFieldAsset;
	import org.tbyrne.display.assets.states.IStateDef;

	public class TextFieldAsset extends InteractiveObjectAsset implements ITextFieldAsset
	{
		/**
		 * @inheritDoc
		 */
		public function get change():IAct{
			if(!_change){
				_change = new NativeAct(_textField,Event.CHANGE,[this]);
			}
			return _change;
		}
		
		
		override public function set displayObject(value:DisplayObject):void{
			if(super.displayObject!=value){
				if(_textField){
					if(_defaultState){
						if(_stateChanged){
							_textField.defaultTextFormat = _defaultState;
							_textField.setTextFormat(_defaultState);
						}
						_defaultState = null;
					}
				}
				super.displayObject = value;
				if(value){
					_textField = value as TextField;
					_defaultState = _textField.defaultTextFormat;
					CONFIG::debug{
						if(!_textField.embedFonts){
							Log.log(Log.SUSPICIOUS_IMPLEMENTATION,"TextField with embedFonts set to false");
						}
					}
				}else{
					_textField = null;
				}
				if(_change)_change.eventDispatcher = value;
				
			}
		}
		override protected function checkInnerBounds():Boolean {
			if(_innerBounds)return true;
			if(super.checkInnerBounds()){
				// strange gutter/bounds bug with TextFields
				_innerBounds.x += TextFieldGutter.TEXT_FIELD_GUTTER;
				_innerBounds.y += TextFieldGutter.TEXT_FIELD_GUTTER;
				return true;
			}else{
				return false;
			}
		}
		
		
		public function get text():String{
			return _textField.text;
		}
		public function set text(value:String):void{
			_textField.text = value;
			/*if(_lastFormat){
				_textField.setTextFormat(_lastFormat);
			}*/
		}
		public function get type():String{
			return _textField.type;
		}
		public function set type(value:String):void{
			_textField.type = value;
		}
		public function get defaultTextFormat():TextFormat{
			return _textField.defaultTextFormat;
		}
		public function set defaultTextFormat(value:TextFormat):void{
			_textField.defaultTextFormat = value;
		}
		public function get restrict():String{
			return _textField.restrict;
		}
		public function set restrict(value:String):void{
			_textField.restrict = value;
		}
		public function get maxChars():int{
			return _textField.maxChars;
		}
		public function set maxChars(value:int):void{
			_textField.maxChars = value;
		}
		public function get htmlText():String{
			return _textField.htmlText;
		}
		public function set htmlText(value:String):void{
			_textField.htmlText = value;
			if(_lastFormat){
				_textField.setTextFormat(_lastFormat);
			}
		}
		public function get embedFonts():Boolean{
			return _textField.embedFonts;
		}
		public function set embedFonts(value:Boolean):void{
			_textField.embedFonts = value;
		}
		public function get multiline():Boolean{
			return _textField.multiline;
		}
		public function set multiline(value:Boolean):void{
			_textField.multiline = value;
		}
		public function get border():Boolean{
			return _textField.border;
		}
		public function set border(value:Boolean):void{
			_textField.border = value;
		}
		public function get wordWrap():Boolean{
			return _textField.wordWrap;
		}
		public function set wordWrap(value:Boolean):void{
			_textField.wordWrap = value;
		}
		public function get selectable():Boolean{
			return _textField.selectable;
		}
		public function set selectable(value:Boolean):void{
			_textField.selectable = value;
		}
		public function get maxScrollV():int{
			return _textField.maxScrollV;
		}
		public function get maxScrollH():int{
			return _textField.maxScrollH;
		}
		public function get bottomScrollV():int{
			return _textField.bottomScrollV;
		}
		
		
		
		public function get selectionBeginIndex():int{
			return _textField.selectionBeginIndex;
		}
		public function get selectionEndIndex():int{
			return _textField.selectionEndIndex;
		}
		public function get textWidth():Number{
			return _textField.textWidth;
		}
		public function get textHeight():Number{
			return _textField.textHeight;
		}
		
		public function get autoSize():String{
			return _textField.autoSize;
		}
		public function set autoSize(value:String):void{
			_textField.autoSize = value;
		}
		
		
		private var _textField:TextField;
		protected var _change:NativeAct;
		protected var _lastFormat:TextFormat;
		protected var _lastFormatName:String;
		protected var _defaultState:TextFormat;
		protected var _stateChanged:Boolean;
		
		public function TextFieldAsset(factory:NativeAssetFactory=null){
			super(factory);
		}
		override protected function onAddedToStage():void{
			super.onAddedToStage();
			enterFrame.addTempHandler(onFirstFrame);
		}
		override protected function onRemovedFromStage():void{
			super.onRemovedFromStage();
			enterFrame.removeHandler(onFirstFrame);
		}
		protected function onFirstFrame(e:Event, from:IDisplayAsset):void {
			findAvailableStates();
		}
		
		public function setTextFormat(format:TextFormat, beginIndex:int  = -1, endIndex:int  = -1):void{
			_textField.setTextFormat(format, beginIndex, endIndex);
		}
		public function setSelection(beginIndex:int, endIndex:int):void{
			_textField.setSelection(beginIndex, endIndex);
		}
		override protected function isStateNameAvailable(stateName:String):Boolean {
			// (_textField.parent is MovieClip) is the cheapest way to check if the parent is dynamic (there could be a better way long term).
			if(_textField.name && _textField.parent && (_textField.parent is MovieClip)){
				var format:TextFormat = getStateNameFormat(stateName);
				if(format){
					_lastFormatName = stateName;
					_lastFormat = format;
				}
				return (format!=null);
			}else{
				return false;
			}
		}
		
		override protected function applyState(state:IStateDef, stateName:String, appliedStates:Array):Number {
			var ret:Number = super.applyState(state, stateName, appliedStates);
			
			if(appliedStates.length)return ret;
			
			if(_lastFormatName!=stateName){
				// if the last state checked doesn't match this one we check again to get the correct format reference
				if(!isStateNameAvailable(stateName)){
					return ret;
				}
			}
			
			if(_lastFormat){
				_stateChanged = true;
				_textField.setTextFormat(_lastFormat);
				_textField.defaultTextFormat = _lastFormat;
			}
			return ret;
		}
		protected function getStateNameFormat(state:String):TextFormat{
			var formatName:String = _textField.name+"_"+state;
			return _textField.parent[formatName];
		}
	}
}