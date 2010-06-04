package au.com.thefarmdigital.debug.debugNodes
{
	import au.com.thefarmdigital.debug.toolbar.IDebugToolbar;
	
	import flash.display.DisplayObject;
	import flash.events.IEventDispatcher;
	
	[Event(name="nodeChange", type="au.com.thefarmdigital.debug.events.DebugNodeEvent")]
	public interface IDebugNode extends IEventDispatcher
	{
		function get appearAsButton():Boolean;
		function get icon():DisplayObject;
		function get label():String;
		function get labelColour():Number;
		function get childNodes(): Array;
		function set parentToolbar(value: IDebugToolbar): void;
		function set selected(value:Boolean):void;
		
	}
}