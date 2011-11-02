package org.tbyrne.composeLibrary.types.display2D
{
	import org.tbyrne.compose.traits.ITrait;

	public interface IHitTestTrait extends ITrait
	{
		function hitTest(trait:ITrait, screenX:Number, screenY:Number):Boolean;
		//function hitTestMany(traits:Vector.<ITrait>, screenX:Number, screenY:Number):ITrait;
	}
}