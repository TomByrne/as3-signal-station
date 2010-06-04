package au.com.thefarmdigital.debug.nodeConfigs
{
	import au.com.thefarmdigital.debug.debugNodes.IDebugNode;
	import au.com.thefarmdigital.debug.debugNodes.siteStream.UnresolvedNodesDebugNode;
	
	import org.farmcode.siteStream.AbstractSiteStream;

	public class SiteStreamNodes
	{
		public static function getSiteStreamNodeTree(siteStream:AbstractSiteStream):IDebugNode{
			var unresolvedNode:UnresolvedNodesDebugNode = new UnresolvedNodesDebugNode(siteStream, "Pending SiteStream: %s");
			return unresolvedNode;
		}
	}
}