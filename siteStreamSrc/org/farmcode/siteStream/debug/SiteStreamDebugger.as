package org.farmcode.siteStream.debug
{
	import org.farmcode.siteStream.AbstractSiteStream;
	import org.farmcode.siteStream.SiteStreamNamespace;
	import org.farmcode.siteStream.SiteStreamNode;
	
	use namespace SiteStreamNamespace;
	
	public class SiteStreamDebugger
	{
		private var _siteStream:AbstractSiteStream;
		
		public function SiteStreamDebugger(siteStream:AbstractSiteStream){
			_siteStream = siteStream;
		}
		public function printUnresolvedNodes():void{
			var tracer:Function = function(node:SiteStreamNode):String{
				if(!node.allResolved){
					return node.id+" (dataLoaded - "+node.dataLoaded+")";
				}else{
					return null;
				}
			}
			NodeTreeTracer.traceTree(_siteStream.rootNode,tracer);
		}
	}
}