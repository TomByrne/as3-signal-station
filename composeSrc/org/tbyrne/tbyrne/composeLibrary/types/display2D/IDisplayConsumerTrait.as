package org.tbyrne.tbyrne.composeLibrary.types.display2D
{
	import flash.display.DisplayObject;
	
	import org.tbyrne.tbyrne.compose.traits.ITrait;
	
	public interface IDisplayConsumerTrait extends ITrait
	{
		function set displayObject(value:DisplayObject):void;
	}
}