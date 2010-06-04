package au.com.thefarmdigital.external
{
	import flash.external.ExternalInterface;
	
	// TODO: Should initialise a different browser object depending on the context, but should be a 
	// global point of access
	public class BrowserUtils
	{
		public static function get windowClosable(): Boolean
		{
			var result: Boolean = false;
			if (ExternalInterface.available)
			{
				result = ExternalInterface.call("function(){return this.opener != null;}"); 
			}
			return result;
		}
	}
}