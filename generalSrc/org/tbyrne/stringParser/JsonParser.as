package org.tbyrne.stringParser
{
	import flash.utils.Dictionary;
	
	import org.tbyrne.stringParser.parsers.BracketPairParser;
	import org.tbyrne.stringParser.parsers.ICharacterParser;
	import org.tbyrne.stringParser.parsers.NameValuePairParser;
	import org.tbyrne.stringParser.parsers.QuotedStringParser;

	public class JsonParser
	{
		public static function get jsonConfig():Vector.<ICharacterParser>{
			checkInit();
			return _jsonConfig;
		}
		public static function get objectParser():BracketPairParser{
			checkInit();
			return _objectParser;
		}
		public static function get arrayParser():BracketPairParser{
			checkInit();
			return _arrayParser;
		}
		public static function get stringParser():QuotedStringParser{
			checkInit();
			return _quotStringParser;
		}
		public static function get nameValueParser():NameValuePairParser{
			checkInit();
			return _nameValueParser;
		}
		
		private static var _jsonConfig:Vector.<ICharacterParser>;
		private static var _objectParser:BracketPairParser;
		private static var _arrayParser:BracketPairParser;
		private static var _quotStringParser:QuotedStringParser;
		private static var _nameValueParser:NameValuePairParser;
		
		private static function checkInit():void{
			if(!_jsonConfig){
				_jsonConfig = new Vector.<ICharacterParser>();
				
				_objectParser = new BracketPairParser("{","}",null,",");
				_jsonConfig.push(_objectParser);
				
				_arrayParser = new BracketPairParser("[","]",null,",");
				_jsonConfig.push(_arrayParser);
				
				_quotStringParser = new QuotedStringParser();
				
				_nameValueParser = new NameValuePairParser(_quotStringParser,[_quotStringParser,_objectParser,_arrayParser],":");
				
				_objectParser.childParsers = [_nameValueParser];
				_arrayParser.childParsers = [_quotStringParser,_objectParser,_arrayParser];
			}
		}
		
		
		
		
		public function get json():String{
			return _stringParser.inputString;
		}
		public function set json(value:String):void{
			_stringParser.inputString = value;
		}
		
		public function get result():Object{
			return _result;
		}
		
		private var _stringParser:StringParser;
		private var _iterator:StringParserIterator;
		
		private var _result:Object;
		private var _nameValueMode:Boolean;
		private var _nextPropName:String;
		
		private var _objectMap:Dictionary; //  id > *
		
		
		public function JsonParser(json:String=null){
			_stringParser = new StringParser(null,jsonConfig);
			_iterator = new StringParserIterator(_stringParser);
			
			this.json = json;
		}
		
		public function interpretSynchronous():Object{
			if(_stringParser.totalSteps>_stringParser.progress){
				_stringParser.parseSynchronous();
			}
			
			_result = null;
			_objectMap = new Dictionary();
			_iterator.iterateSynchronous(interpret);
			return _result;
		}
		
		private function interpret(id:String, parentId:String, parser:ICharacterParser, strings:*):void{
			var value:*;
			
			if(_objectMap[id]!=null){
				_objectMap[id];
			}
			
			switch(parser){
				case _nameValueParser:
					_nameValueMode = true;
					_objectMap[id] = _objectMap[parentId];
					return;
				case _objectParser:
					value = {};
					break;
				case _arrayParser:
					value = [];
					break;
				case _quotStringParser:
					if(_nameValueMode && !_nextPropName){
						_nextPropName = strings as String;
						return 
					}
					value = strings;
					break;
			}
			_objectMap[id] = value;
			if(!_result){
				_result = value;
			}else{
				var parentObject:* = _objectMap[parentId];
				if(_nameValueMode){
					parentObject[_nextPropName] = value;
					_nameValueMode = false;
					_nextPropName = null;
				}else if(parentObject is Array){
					parentObject.push(value);
				}
			}
		}
	}
}