package org.tbyrne.debug.data.baseMetrics
{
	import org.tbyrne.data.dataTypes.ITriggerableAction;
	import org.tbyrne.display.assets.assetTypes.IDisplayAsset;
	import org.tbyrne.memory.garbageCollect;
	
	public class GarbageCollect implements ITriggerableAction
	{
		public function GarbageCollect()
		{
		}
		
		public function triggerAction(scopeDisplay:IDisplayAsset):void
		{
			garbageCollect();
		}
	}
}