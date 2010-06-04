package au.com.thefarmdigital.display.containerBinding
{
	import flash.display.DisplayObject;
	
	public interface IContainerBinding
	{
		function set display(value: DisplayObject): void;
		function get display(): DisplayObject;
	}
}