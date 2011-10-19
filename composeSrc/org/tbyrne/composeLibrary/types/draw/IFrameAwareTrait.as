package org.tbyrne.composeLibrary.types.draw
{
	import org.tbyrne.compose.traits.ITrait;
	
	public interface IFrameAwareTrait extends ITrait
	{
		function setSize(width:Number, height:Number):void;
	}
}