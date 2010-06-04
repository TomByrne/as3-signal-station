package au.com.thefarmdigital.debug.infoSources
{
	import flash.events.IEventDispatcher;
	
	[Event(name="outputChange", type="au.com.thefarmdigital.debug.events.InfoSourceEvent")]
	public interface IInfoSource extends IEventDispatcher
	{
		function set enabled(value: Boolean): void;
		function get output(): *;
		function get labelColour(): Number;
	}
}