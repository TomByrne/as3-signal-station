
package org.tbyrne.debug.logging
{

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	
	//PLATFORM::air{
	import flash.filesystem.*;
	//}

	public class XMLFileLogger extends AbstractLogger implements ILogger
	{
		PLATFORM::air{
		
		private var _file:File;
		private var _fileStream:FileStream;
		
		private var _log:XML;
		private var _pendingNodes:Vector.<XML>;
		
		private var _busy:Boolean;
		private var _invalid:Boolean;
		
		public function XMLFileLogger(logName:String="log")
		{
			var now:Date = new Date();
			var timestamp:String = (now.fullYear)+"-"+(now.month+1)+"-"+now.date;
			var path:String = File.applicationStorageDirectory.nativePath+"\\"+logName+"_"+timestamp+".xml";
			_file = new File(path);
			
			
			if(_file.exists){
				_busy = true;
				_fileStream = new FileStream();
				_fileStream.openAsync(_file, flash.filesystem.FileMode.READ);
				_fileStream.addEventListener(Event.COMPLETE, fileReadHandler);
				_fileStream.addEventListener(IOErrorEvent.IO_ERROR, readIOErrorHandler);
			}else{
				_log = <log/>;
				_log.@date = timestamp;
			}
		}
		
		
		public function log(level:int, ...params):void{
			var now:Date = new Date();
			var levelName:String = getLevelName(level);
			var node:XML = <logEntry/>;
			node.@time = now.hours+":"+now.minutes+":"+now.seconds;
			node.appendChild(new XML([levelName].concat(params).join(" ")));
			if(_log){
				_log.appendChild(node);
			}else{
				if(!_pendingNodes)_pendingNodes = new Vector.<XML>();
				_pendingNodes.push(node);
			}
			
			if(_busy){
				_invalid = true;
			}else{
				writeFile();
			}
		}
		
		protected function fileReadHandler(event:Event):void{
			_log = new XML(_fileStream.readUTFBytes(_fileStream.bytesAvailable));
			if(_pendingNodes){
				for each(var node:XML in _pendingNodes){
					_log.appendChild(node);
				}
				_pendingNodes = null;
			}
			finishRead();
		}
		
		
		protected function readIOErrorHandler(event:Event):void{
			finishRead();
			throw new Error("Couldn't read log file: "+_file.nativePath);
		}
		
		private function finishRead():void{
			_busy = false;
			_fileStream.removeEventListener(Event.COMPLETE, fileReadHandler);
			_fileStream.removeEventListener(IOErrorEvent.IO_ERROR, readIOErrorHandler);
			
			_fileStream.close();
			_fileStream = null;
			
			if(_invalid){
				_invalid = false;
				writeFile()
			}
		}
		
		private function writeFile():void{
			_busy = true;
			_fileStream = new FileStream();
			_fileStream.addEventListener(IOErrorEvent.IO_ERROR, writeIOErrorHandler);
			_fileStream.openAsync(_file, FileMode.WRITE);
			_fileStream.writeUTFBytes(_log.toXMLString());
			_fileStream.close();
			_fileStream.removeEventListener(IOErrorEvent.IO_ERROR, writeIOErrorHandler);
		}
		
		protected function writeIOErrorHandler(event:Event):void{
			_fileStream.removeEventListener(IOErrorEvent.IO_ERROR, writeIOErrorHandler);
			
			_fileStream.close();
			_fileStream = null;
			
			throw new Error("Couldn't write log file: "+_file.nativePath);
		}
		
		}
		PLATFORM::web{
		public function log(level:int, ...params):void{
			// @todo implement
		}
		}
	}
}
