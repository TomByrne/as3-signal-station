package org.tbyrne.siteStream
{
	
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
			_node.wasParsed.addHandler(onNodeReady);
			if(!_node.dataLoaded)_node.beginResolve();
		}
		override protected function stopWaitingForNode(_node:SiteStreamNode):void{
			_node.wasParsed.removeHandler(onNodeReady);
		}
		override protected function dispatchResolved():void{
			var value:* = _node.propertyInfo.value;
			for each(var prop:String in propPath){
				value = value[prop];
				if(value==null){
					Log.error("ReferenceNodeResolver.dispatchResolved: Referenced value couldn't be found");
				}
			}
			propertySetter.value = value;
			super.dispatchResolved();
		}
	}
}