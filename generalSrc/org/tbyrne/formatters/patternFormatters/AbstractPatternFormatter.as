package org.tbyrne.formatters.patternFormatters
{
	import flash.utils.Dictionary;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.data.dataTypes.IStringProvider;
	import org.tbyrne.display.validation.ValidationFlag;
	
	public class AbstractPatternFormatter implements IStringProvider
	{
		/**
		 * If quickValidate is true, the pattern will be reevaluated before
		 * the stringValueChanged act is performed, this will prevent the act
		 * from being fired when there is no actual change to the resulting
		 * stringValue. The downside is that even if nothing was listening to
		 * the act the pattern will still be reevaluated.
		 */
		public var quickValidate:Boolean;
		
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
		
		protected var _quickValidate:Boolean;
		protected var _stringValue:String;
		protected var _stringValueFlag:ValidationFlag;
		protected var _stringValueChanged:Act;
		protected var _pattern:IStringProvider;
		protected var _tokens:Dictionary;
		
		public function AbstractPatternFormatter(pattern:IStringProvider=null){
			_stringValueFlag = new ValidationFlag(validateString,false);
			this.pattern = pattern;
			_tokens = new Dictionary();
		}
		protected function _addToken(token:String, stringProvider:IStringProvider):void{
			if(_tokens[token]){
				_removeToken(token);
			}
			_tokens[token] = stringProvider;
			if(stringProvider)stringProvider.stringValueChanged.addHandler(onTokenChanged);
			doStringChanged();
		}
		protected function _removeToken(token:String):void{
			if(!_tokens[token])return;
			var stringProvider:IStringProvider = _tokens[token];
			if(stringProvider)stringProvider.stringValueChanged.removeHandler(onTokenChanged);
			delete _tokens[token];
			doStringChanged();
		}
		protected function _removeAllTokens():void{
			for(var token:String in _tokens){
				_removeToken(token);
			}
		}
		
		protected function onPatternChanged(from:IStringProvider):void{
			doStringChanged();
		}
		protected function onTokenChanged(from:IStringProvider):void{
			doStringChanged();
		}
		protected function doStringChanged():void{
			if(quickValidate){
				var oldString:String = _stringValue;
				_stringValueFlag.validate(true);
				if(oldString!=_stringValue && _stringValueChanged)_stringValueChanged.perform(this);
			}else{
				_stringValueFlag.invalidate();
				if(_stringValueChanged)_stringValueChanged.perform(this);
			}
		}
		protected function validateString():void{
			if(_pattern){
				_stringValue = _pattern.stringValue;
				if(_stringValue){
					for(var token:String in _tokens){
						var provider:IStringProvider = _tokens[token];
						if(!provider){
							_stringValue = null;
							return;
						}
						var val:String = provider.stringValue;
						if(!val)val = "";
						_stringValue = _stringValue.replace(token,val);
					}
				}
			}else{
				_stringValue = null;
			}
		}
	}
}