package org.tbyrne.data.actions
{
	import flash.display.DisplayObject;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.data.dataTypes.ITriggerableAction;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
	
	public class TriggerableAction implements ITriggerableAction
	{
		public function TriggerableAction()
		{
		}
		
		public function triggerAction(scopeDisplay:IDisplayObject):void{
			var act:IAct = getAct();
			if(act){
				var params:Array = getParams();
				act.perform.apply(null,params);
			}else{
				Log.log(Log.SUSPICIOUS_IMPLEMENTATION,"no IAct associated with TriggerableAction");
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