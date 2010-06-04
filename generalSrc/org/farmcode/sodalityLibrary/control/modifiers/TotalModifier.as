package org.farmcode.sodalityLibrary.control.modifiers
{
	public class TotalModifier extends AbstractNumberModifier
	{
		private var total:Number = 0;
		
		override public function inputNumber(value:Number, oldValue:Number):Number{
			total += value;
			return total;
		}
	}
}