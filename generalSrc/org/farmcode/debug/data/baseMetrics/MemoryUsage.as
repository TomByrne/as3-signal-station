package org.farmcode.debug.data.baseMetrics
{
	import flash.system.System;
	import org.farmcode.debug.data.core.NumberMonitor;

	public class MemoryUsage extends NumberMonitor
	{
		public function MemoryUsage(){
			super(System, "totalMemory");
		}
	}
}