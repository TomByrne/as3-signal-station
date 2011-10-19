package org.tbyrne.composeLibrary.types.draw
{
	import org.tbyrne.compose.traits.ITrait;

	public interface IDrawAwareTrait extends ITrait
	{
		function tick(timeStep:Number):void;
	}
}