package org.tbyrne.composeLibrary.display2D.types
{
	import org.tbyrne.compose.traits.ITrait;

	public interface IHitTestTrait extends ITrait
	{
		function hitTest(trait:ITrait, screenX:Number, screenY:Number):Boolean;
		//function hitTestMany(traits:Vector.<ITrait>, screenX:Number, screenY:Number):ITrait;
	}
}