package org.tbyrne.tbyrne.composeLibrary.types.draw
{
	import org.tbyrne.tbyrne.compose.traits.ITrait;

	public interface IDrawAwareTrait extends ITrait
	{
		function tick(timeStep:Number):void;
	}
}