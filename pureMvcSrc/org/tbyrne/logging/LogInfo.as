package org.tbyrne.logging
{
	public class LogInfo
	{
		public var level:int;
		public var params:Array;
		public var loggedAt:int;
		
		public function LogInfo(level:int, params:Array, loggedAt:int){
			this.level = level;
			this.params = params;
			this.loggedAt = loggedAt;
		}
	}
}