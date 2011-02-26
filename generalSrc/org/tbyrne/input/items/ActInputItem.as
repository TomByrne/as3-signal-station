package org.tbyrne.input.items
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.data.dataTypes.IStringProvider;
	import org.tbyrne.data.dataTypes.ITriggerableAction;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
	import org.tbyrne.input.menu.IMenuInputItem;
	import org.tbyrne.input.shortcuts.IShortcutInputItem;

	public class ActInputItem extends AbstractInputItem implements ITriggerableAction, IShortcutInputItem, IMenuInputItem
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
		
		public function ActInputItem(stringProvider:IStringProvider=null, act:IAct=null, params:Array=null){
			super(stringProvider);
			this.act = act;
			this.params = params;
		}
		override public function triggerAction(scopeDisplay:IDisplayObject):void{
			if(!_act){
				Log.log(Log.SUSPICIOUS_IMPLEMENTATION,"no IAct associated with ActNavItem");
			}else{
				_act.perform.apply(null,_params);
			}
		}
	}
}