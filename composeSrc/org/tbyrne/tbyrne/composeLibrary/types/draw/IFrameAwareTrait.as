package org.tbyrne.tbyrne.composeLibrary.types.draw
{
	import org.tbyrne.tbyrne.compose.traits.ITrait;
	
	public interface IFrameAwareTrait extends ITrait
	{
		function setSize(width:Number, height:Number):void;
	}
}