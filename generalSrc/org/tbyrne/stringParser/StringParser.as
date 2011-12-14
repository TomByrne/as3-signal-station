package org.tbyrne.stringParser
{
	import flash.utils.Dictionary;
	
	import org.tbyrne.stringParser.parsers.ICharacterParser;
	import org.tbyrne.stringParser.parsers.WhitespaceParser;

	public class StringParser
	{
		public function get inputString():String{
			return _inputString;
		}
		public function set inputString(value:String):void{
			if(_inputString!=value){
				reset();
				_inputString = value;
				init();
			}
		}
		
		public function get config():Vector.<ICharacterParser>{
			return _config;
		}
		public function set config(value:Vector.<ICharacterParser>):void{
			if(_config!=value){
				reset();
				_config = value;
				init();
			}
		}
		
		public function get trimWhitespace():Boolean{
			return _trimWhitespace;
		}
		public function set trimWhitespace(value:Boolean):void{
			if(_trimWhitespace!=value){
				reset();
				_trimWhitespace = value;
				if(value && !_whitespaceParser){
					_whitespaceParser = WhitespaceParser.instance;
				}
				init();
			}
		}
		
		
		public function get totalSteps():int{
			return _totalSteps;
		}
		public function get progress():int{
			return _progress;
		}
		
		
		public function get firstPacketId():String{
			return _firstPacketId;
		}
		public function get totalPackets():int{
			return _totalPackets;
		}
		
		private var _config:Vector.<ICharacterParser>;
		private var _inputString:String;
		private var _progress:int = -1;
		private var _idsAtIndex:int = -1;
		private var _totalSteps:int = -1;
		private var _trimWhitespace:Boolean;
		
		private var _firstPacketId:String;
		private var _totalPackets:int = -1;
		private var _strings:Dictionary; // id > String | [String]
		private var _parents:Dictionary; // id > id
		private var _firstChild:Dictionary; // id > id
		private var _lastChild:Dictionary; // id > id
		private var _nextSibling:Dictionary; // id > id
		private var _parsers:Dictionary; // id > ICharacterParser
		
		private var _currentId:String;
		private var _currentParser:ICharacterParser;
		private var _finishedOnCurrent:Boolean;
		private var _startCurrentString:int = -1;
		
		private var _currentOptions:Vector.<ICharacterParser>;
		//private var _openParsers:Vector.<ICharacterParser>;
		private var _openParserIds:Vector.<String>;
		
		private var _whitespaceParser:WhitespaceParser;
		
		public function StringParser(inputString:String=null, config:Vector.<ICharacterParser>=null, trimWhitespace:Boolean=true){
			this.inputString = inputString;
			this.config = config;
			this.trimWhitespace = trimWhitespace;
		}
		
		
		private function reset():void{
			if(_inputString && _config){
				_progress = -1;
				_totalSteps = -1;
				_startCurrentString = -1;
				_currentId = null;
				_totalPackets = -1;
				_firstPacketId = null;
				_idsAtIndex = -1;
				
				//_openParsers = null;
				_currentOptions = null;
				_strings = null;
				_parsers = null;
				_parents = null;
				_firstChild = null;
				_lastChild = null;
				_nextSibling = null;
			}
		}
		private function init():void{
			if(_inputString && _config){
				_progress = 0;
				_idsAtIndex = 0;
				_totalSteps = _inputString.length;
				_currentId = null;
				_totalPackets = 0;
				
				//_openParsers = new Vector.<ICharacterParser>();
				_openParserIds = new Vector.<String>();
				_currentOptions = _config;
				_strings = new Dictionary();
				_parsers = new Dictionary();
				_parents = new Dictionary();
				_firstChild = new Dictionary();
				_lastChild = new Dictionary();
				_nextSibling = new Dictionary();
			}
		}
		
		public function parseSynchronous():void{
			while(_progress<_totalSteps){
				parseStep();
			}
		}
		
		public function parseStep():void{
			var char:String = _inputString.charAt(_progress);
			var newParserId:String;
			var newParser:ICharacterParser;
			
			if((!_currentParser || _finishedOnCurrent) && skipWhitespsace(char)){
				// ignore
			}else{
				//var nextId:String = getNextId();
				if(!_currentParser){
					newParserId = findCurrentParser(char,null,_currentOptions);
					newParser = _parsers[newParserId];
					if(!newParser){
						Log.error("No parser found");
					}
					_firstPacketId = newParserId;
					setCurrentParser(newParser,newParserId,_currentId);
					_finishedOnCurrent = false;
				}else{
					if(newParserId = testParser(char,_currentParser,_currentId,_parents[_currentId],true)){
						newParser = _parsers[newParserId];
						if(newParser!=_currentParser){
							//nextId = getNextId();
							setCurrentParser(newParser,newParserId,_currentId);
							_finishedOnCurrent = false;
						}
					}else if(!skipWhitespsace(char)){
						storeCurrentString();
						var firstTry:Boolean = true;
						
						var oldCurrId:String = _currentId;
						
						var i:int=0;
						while(i<_openParserIds.length && (_finishedOnCurrent || firstTry)){
							
							var parentId:String = _openParserIds[_openParserIds.length-1-i];
							var parentParser:ICharacterParser = _parsers[parentId];
							newParserId = testParser(char,parentParser,parentId,_parents[parentId],true);
							newParser = _parsers[newParserId];
							firstTry = false;
							
							if(newParser){
								//_openParsers.splice(_openParsers.length-1-i,i+1);
								_openParserIds.splice(_openParserIds.length-1-i,i+1);
								
								if(newParser==parentParser){
									_currentId = parentId;
									_currentParser = newParser;
								}else{
									setCurrentParser(newParser,newParserId,_parents[newParserId]);
								}
								_finishedOnCurrent = false;
								break;
							}
							++i;
						}
						if(!newParser)_finishedOnCurrent = true;
					}else{
						_finishedOnCurrent = true;
					}
				}
				if(_currentParser && !_finishedOnCurrent){
					if(_currentParser.parseCharacter(char,_currentId)){
						if(_startCurrentString==-1){
							_startCurrentString = _progress;
						}
					}else{
						storeCurrentString();
					}
				}
			}
			
			++_progress;
			_idsAtIndex = 0;
		}
		
		private function getNextId():String{
			return _progress+" "+_idsAtIndex;
		}
		
		private function setCurrentParser(parser:ICharacterParser, id:String, parentId:String):void{
			_currentParser = parser;
			_currentId = id;
			_parsers[id] = parser;
			_parents[id] = parentId;
			
			_idsAtIndex++;
			
			if(parentId){
				var lastChild:* = _lastChild[parentId];
				if(lastChild==null){
					_firstChild[parentId] = id;
				}else{
					_nextSibling[lastChild] = id;
				}
				_lastChild[parentId] = id;
			}
			
			++_totalPackets;
		}
		
		private function skipWhitespsace(char:String):Boolean{
			return (_trimWhitespace && _whitespaceParser.acceptCharacter(char,null));
		}
		private function storeCurrentString():void{
			if(_startCurrentString!=-1){
				var string:String = _inputString.substring(_startCurrentString,_progress);
				var value:* = _strings[_currentId];
				var array:Array;
				if(value==null){
					_strings[_currentId] = string;
				}else if(array = (value as Array)){
					array.push(string);
				}else{
					_strings[_currentId] = [string,value];
				}
				_startCurrentString = -1;
			}
		}
		
		private function findCurrentParser(char:String, parentId:String, inParsers:Vector.<ICharacterParser>):String{
			var nextId:String = getNextId();
			var childId:String;
			for each(var parser:ICharacterParser in inParsers){
				if(childId = testParser(char,parser,nextId,parentId,false)){
					return childId;
				}
			}
			return null;
		}
		
		private function testParser(char:String, parser:ICharacterParser, id:String, parentId:String, allowOptionRecover:Boolean):String
		{
			var newOptions:Vector.<ICharacterParser> = parser.acceptCharacter(char,id);
			
			if(!newOptions && _currentOptions && allowOptionRecover){
				newOptions = _currentOptions;
			}
			if(newOptions){
				if(!_parsers[id]){
					_parsers[id] = parser;
					_parents[id] = parentId;
					++_idsAtIndex;
				}
				
				if(newOptions.length>1 || newOptions[0]!=parser){
					_currentOptions = newOptions;
					if(skipWhitespsace(char)){
						return null;
					}else{
						var index:int = _openParserIds.length;
						var childId:String = findCurrentParser(char, id, newOptions);
						if(childId){
							storeCurrentString();
							_openParserIds.splice(index,0,id);
						}
						return childId;
					}
				}else{
					_currentOptions = null;
					return id;
				}
			}else{
				_currentOptions = null;
				return null;
			}
		}
		
		
		
		public function getParent(packetId:String):String{
			return _parents[packetId];
		}
		public function getFirstChild(packetId:String):String{
			return _firstChild[packetId];
		}
		public function getNextSibling(packetId:String):String{
			return _nextSibling[packetId];
		}
		public function getParser(packetId:String):ICharacterParser{
			return _parsers[packetId];
		}
		public function getStrings(packetId:String):*{
			return _strings[packetId];
		}
	}
}