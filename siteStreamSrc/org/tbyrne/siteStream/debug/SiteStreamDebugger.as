package org.tbyrne.siteStream.debug
{
	import org.tbyrne.siteStream.AbstractSiteStream;
	import org.tbyrne.siteStream.SiteStreamNamespace;
	import org.tbyrne.siteStream.SiteStreamNode;
	
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