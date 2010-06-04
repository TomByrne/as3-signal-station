package au.com.thefarmdigital.effects
{
	import au.com.thefarmdigital.transitions.ITransition;
	
	import flash.display.DisplayObject;
	
	public interface IEffect
	{
		function set subject(value:DisplayObject):void;
		function get subject():DisplayObject;
		
		function render():void;
		function remove():void;
	}
}