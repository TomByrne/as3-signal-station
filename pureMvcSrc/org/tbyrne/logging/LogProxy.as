package org.tbyrne.logging
{
	import flash.utils.getTimer;
	
	import org.puremvc.as3.patterns.proxy.Proxy;
	import org.tbyrne.debug.logging.ILogger;
	
	public class LogProxy extends Proxy implements ILogger, ILogProxy
	{
		protected static const NAME:String = "LogProxy";
		
		private var _visibility:int = -1;
		private var _messages:Vector.<LogInfo>;
		private var _leveled:Array; // leveled isn't dense and so can't be a Vactor
		
		public function LogProxy(){
			super(NAME, this);
			_messages = new Vector.<LogInfo>();
			_leveled = [];
		}
		public function log(level:int, ... params):void{
			var body:LogInfo = new LogInfo(level, params, getTimer());
			_messages.push(body);
			var leveled:Vector.<LogInfo>;
			if(level<_leveled.length){
				leveled = _leveled[level];
			}
			if(!leveled){
				leveled = new Vector.<LogInfo>();
				_leveled[level] = leveled;
			}
			leveled.push(body);
			if(_visibility==-1 || level<_visibility){
				sendNotification(LogNotifications.LOG, body);
			}
		}
		public function setVisibility(level:int):void{
			_visibility = level;
		}
		public function getMessagesForLevel(level:int):Vector.<LogInfo>{
			return _leveled[level];
		}
	}
}