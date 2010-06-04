package au.com.thefarmdigital.display.controls
{
	import flash.events.IEventDispatcher;
	import flash.text.TextField;
	
	[Event(name="click",type="flash.events.MouseEvent")]
	[Event(name="rollOver",type="flash.events.MouseEvent")]
	public interface ISelectableControl extends IEventDispatcher, IControl
	{
		function set highlit(value:Boolean):void;
		function get data():*;
		function get mouseOver():Boolean;
		function set data(value:*):void;
		function set label(value:String):void;
		function set selected(value:Boolean):void;
		function get selected():Boolean;
		function get labelField():TextField;
		
	}
}