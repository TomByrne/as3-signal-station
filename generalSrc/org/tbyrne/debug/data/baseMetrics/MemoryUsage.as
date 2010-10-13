package org.tbyrne.debug.data.baseMetrics
{
	import flash.system.System;
	import org.tbyrne.debug.data.core.NumberMonitor;

	public class MemoryUsage extends NumberMonitor
	{
		public function MemoryUsage(){
			super(System, "totalMemory");
		}
	}
}