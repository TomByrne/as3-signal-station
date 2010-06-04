package au.com.thefarmdigital.debug.nodeConfigs
{
	import au.com.thefarmdigital.debug.debugNodes.IDebugNode;
	import au.com.thefarmdigital.debug.debugNodes.sodality.PendingExecutionDebugNode;
	
	import org.farmcode.sodality.President;

	public class SodalityNodes
	{
		public static function getSodalityNodeTree(president:President):IDebugNode{
			var pendingNode:PendingExecutionDebugNode = new PendingExecutionDebugNode(president, "Pending Executions: %s");
			return pendingNode;
		}
	}
}