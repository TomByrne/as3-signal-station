package org.tbyrne.data.navigation
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.data.dataTypes.ITriggerableAction;
	import org.tbyrne.debug.logging.Log;
	import org.tbyrne.display.assets.assetTypes.IDisplayAsset;

	public class ActNavItem extends AbstractNavItem implements ITriggerableAction
	{
		public function get act():IAct{
			return _act;
		}
		public function set act(value:IAct):void{
			_act = value;
		}
		
		public function get params():Array{
			return _params;
		}
		public function set params(value:Array):void{
			_params = value;
		}
		
		private var _params:Array;
		private var _act:IAct;
		
		public function ActNavItem(stringValue:String=null, act:IAct=null, params:Array){
			super(stringValue);
			this.act = act;
			this.params = params;
		}
		public function triggerAction(scopeDisplay:IDisplayAsset):void{
			if(!_act){
				Log.log(Log.SUSPICIOUS_IMPLEMENTATION,"no IAct associated with ActNavItem");
			}else{
				_act.perform.apply(null,_params);
			}
		}
	}
}