package org.farmcode.sodalityLibrary.control.modifiers
{
	import flash.events.EventDispatcher;

	public class AbstractNumberModifier extends EventDispatcher implements INumberModifier
	{
		public function inputNumber(value:Number, oldValue:Number):Number{
			return NaN;
		}
		
		public function input(value:*, oldValue:*):*{
			return inputNumber(value as Number, oldValue as Number);
		}
		
	}
}