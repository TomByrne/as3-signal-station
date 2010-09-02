package org.farmcode.debug.data.baseMetrics
{
	import org.farmcode.data.dataTypes.ITriggerableAction;
	import org.farmcode.display.assets.assetTypes.IDisplayAsset;
	import org.farmcode.memory.garbageCollect;
	
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