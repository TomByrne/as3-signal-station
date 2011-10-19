package org.tbyrne.composeLibrary.types.display2D
{
	import flash.display.DisplayObject;
	
	import org.tbyrne.compose.traits.ITrait;
	
	public interface IDisplayConsumerTrait extends ITrait
	{
		function set displayObject(value:DisplayObject):void;
	}
}