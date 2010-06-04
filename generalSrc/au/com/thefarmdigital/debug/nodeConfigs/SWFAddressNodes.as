package au.com.thefarmdigital.debug.nodeConfigs
{
	import au.com.thefarmdigital.debug.debugNodes.IDebugNode;
	import au.com.thefarmdigital.debug.debugNodes.TextInputDebugNode;
	import au.com.thefarmdigital.debug.infoSources.SWFAddressInfoSource;

	public class SWFAddressNodes
	{
		public static function getSWFAddressNodeTree():IDebugNode{
			return new TextInputDebugNode(new SWFAddressInfoSource(),200);
		}
	}
}