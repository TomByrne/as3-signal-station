package org.farmcode.data.actions
{
	import flash.display.DisplayObject;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.data.dataTypes.ITriggerableAction;
	import org.farmcode.display.assets.assetTypes.IDisplayAsset;
	
	public class TriggerableAction implements ITriggerableAction
	{
		public function TriggerableAction()
		{
		}
		
		public function triggerAction(scopeDisplay:IDisplayAsset):void{
			var act:IAct = getAct();
			if(act){
				var params:Array = getParams();
				act.perform(params);
			}else{
				trace("WARNING: no IAct associated with TriggerableAction");
			}
		}
		protected function getAct():IAct{
			return null;
		}
		protected function getParams():Array{
			return null;
		}
	}
}