package org.farmcode.debug.data.core
{
	import flash.system.System;

	public class MemoryUsage extends NumberMonitor
	{
		public function MemoryUsage(){
			super(System, "totalMemory");
		}
	}
}