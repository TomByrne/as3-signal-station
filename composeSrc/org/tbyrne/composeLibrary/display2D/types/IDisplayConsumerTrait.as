package org.tbyrne.composeLibrary.display2D.types
{
	import flash.display.DisplayObject;
	
	import org.tbyrne.compose.traits.ITrait;
	
	public interface IDisplayConsumerTrait extends ITrait
	{
		function set displayObject(value:DisplayObject):void;
	}
}