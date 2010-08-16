package org.farmcode.formatters.patternFormatters
{
	import flash.utils.Dictionary;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.data.dataTypes.IStringProvider;
	import org.farmcode.display.validation.ValidationFlag;
	
	public class AbstractPatternFormatter implements IStringProvider
	{
		
		public function get pattern():IStringProvider{
			return _pattern;
		}
		public function set pattern(value:IStringProvider):void{
			if(_pattern!=value){
				if(_pattern){
					_pattern.stringValueChanged.removeHandler(onPatternChanged);
				}
				_pattern = value;
				if(_pattern){
					_pattern.stringValueChanged.addHandler(onPatternChanged);
				}
				doStringChanged();
			}
		}
		public function get stringValue():String{
			_stringValueFlag.validate();
			return _stringValue;
		}
		
		public function get value():*{
			return stringValue;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get stringValueChanged():IAct{
			if(!_stringValueChanged)_stringValueChanged = new Act();
			return _stringValueChanged;
		}
		/**
		 * @inheritDoc
		 */
		public function get valueChanged():IAct{
			return stringValueChanged;
		}
		
		protected var _stringValue:String;
		protected var _stringValueFlag:ValidationFlag;
		protected var _stringValueChanged:Act;
		protected var _pattern:IStringProvider;
		protected var _tokens:Dictionary;
		
		public function AbstractPatternFormatter(pattern:IStringProvider){
			_stringValueFlag = new ValidationFlag(validateString,false);
			this.pattern = pattern;
			_tokens = new Dictionary();
		}
		protected function _addToken(token:String, stringProvider:IStringProvider):void{
			Config::DEBUG{
				if(_tokens[token])throw new Error("This token has already been added");
				if(!stringProvider)throw new Error("No IStringProvider provided");
			}
			_tokens[token] = stringProvider;
			stringProvider.stringValueChanged.addHandler(onTokenChanged);
			doStringChanged();
		}
		protected function _removeToken(token:String):void{
			Config::DEBUG{
				if(!_tokens[token])throw new Error("This token hasn't been added");
			}
			var stringProvider:IStringProvider = _tokens[token];
			stringProvider.stringValueChanged.removeHandler(onTokenChanged);
			delete _tokens[token];
			doStringChanged();
		}
		
		protected function onPatternChanged(from:IStringProvider):void{
			doStringChanged();
		}
		protected function onTokenChanged(from:IStringProvider):void{
			doStringChanged();
		}
		protected function doStringChanged():void{
			_stringValueFlag.invalidate();
			if(_stringValueChanged)_stringValueChanged.perform(this);
		}
		protected function validateString():void{
			if(_pattern){
				_stringValue = _pattern.stringValue;
				if(_stringValue){
					for(var token:String in _tokens){
						var provider:IStringProvider = _tokens[token];
						_stringValue = _stringValue.replace(token,provider.stringValue);
					}
				}
			}else{
				_stringValue = null;
			}
		}
	}
}