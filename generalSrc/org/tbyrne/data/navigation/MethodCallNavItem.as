package org.tbyrne.data.navigation
{
	import org.tbyrne.data.core.StringData;
	import org.tbyrne.data.dataTypes.ITriggerableAction;
	import org.tbyrne.display.assets.assetTypes.IDisplayAsset;
	
	public class MethodCallNavItem extends StringData implements ITriggerableAction
	{
		public var methodCall:Function;
		
		public function MethodCallNavItem(stringValue:String=null, methodCall:Function=null){
			super(stringValue);
			this.methodCall = methodCall;
		}
		
		public function triggerAction(scopeDisplay:IDisplayAsset):void{
			methodCall();
		}
	}
}