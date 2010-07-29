package au.com.thefarmdigital.behaviour.behaviours
{
	import org.farmcode.acting.actTypes.IAct;
	
	public interface IBehaviour
	{
		/**
		 * Return true if this behaviour needs no more time.
		 */
		function execute(goals:Array):Boolean;
		/**
		 * handler(from:IBehaviour)
		 */
		function get executionComplete():IAct;
		
		function cancel():void;
		function finish():void;
		function get abortable():Boolean;
	}
}