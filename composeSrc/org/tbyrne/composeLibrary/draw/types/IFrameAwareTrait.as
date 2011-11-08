package org.tbyrne.composeLibrary.draw.types
{
	import org.tbyrne.compose.traits.ITrait;
	
	public interface IFrameAwareTrait extends ITrait
	{
		function setSize(width:Number, height:Number):void;
	}
}