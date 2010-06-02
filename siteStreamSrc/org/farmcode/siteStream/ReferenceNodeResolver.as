package org.farmcode.siteStream
{
	import flash.events.Event;
	
	import org.farmcode.siteStream.events.SiteStreamEvent;
	
	public class ReferenceNodeResolver extends NodeResolver
	{
		protected var propertySetter:IPropertySetter;
		protected var propPath:Array;
		
		public function ReferenceNodeResolver(rootNode:SiteStreamNode, path:String, propertySetter:IPropertySetter){
			propPath = path.split(".");
			super(rootNode, propPath.shift());
			this.propertySetter = propertySetter;
		}
		override protected function isNodeReady(_node:SiteStreamNode):Boolean{
			return _node.dataLoaded && _node.allParsed;
		}
		override protected function waitForNode(_node:SiteStreamNode):void{
			_node.addEventListener(SiteStreamEvent.PARSED, onNodeReady);
			if(!_node.dataLoaded)_node.beginResolve();
		}
		override protected function stopWaitingForNode(_node:SiteStreamNode):void{
			_node.removeEventListener(SiteStreamEvent.PARSED, onNodeReady);
		}
		override protected function dispatchResolved():void{
			var value:* = _node.propertyInfo.value;
			for each(var prop:String in propPath){
				value = value[prop];
				if(value==null){
					throw new Error("Referenced value couldn't be found");
				}
			}
			propertySetter.value = value;
			super.dispatchResolved();
		}
	}
}