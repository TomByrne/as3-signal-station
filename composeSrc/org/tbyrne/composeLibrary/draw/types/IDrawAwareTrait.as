package org.tbyrne.composeLibrary.draw.types
{
	import org.tbyrne.compose.traits.ITrait;

	public interface IDrawAwareTrait extends ITrait
	{
		function tick(timeStep:Number):void;
	}
}