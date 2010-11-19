package org.tbyrne.queueing
{
	public class ThreadSpeed
	{
		public var threadId:String;
		public var intendedThreadSpeed:Number;
		
		public function ThreadSpeed(threadId:String, intendedThreadSpeed:Number)
		{
			this.threadId = threadId;
			this.intendedThreadSpeed = intendedThreadSpeed;
		}
	}
}