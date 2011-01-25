package org.tbyrne.input.items
{
	import org.tbyrne.data.dataTypes.IStringProvider;
	import org.tbyrne.data.dataTypes.ITriggerableAction;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
	import org.tbyrne.input.menu.IMenuInputItem;
	import org.tbyrne.input.shortcuts.IShortcutInputItem;
	
	public class MethodCallInputItem extends AbstractInputItem implements ITriggerableAction, IShortcutInputItem, IMenuInputItem
	{
		public var methodCall:Function;
		
		public function MethodCallInputItem(stringProvider:IStringProvider=null, methodCall:Function=null){
			super(stringProvider);
			this.methodCall = methodCall;
		}
		
		override public function triggerAction(scopeDisplay:IDisplayObject):void{
			methodCall();
		}
	}
}