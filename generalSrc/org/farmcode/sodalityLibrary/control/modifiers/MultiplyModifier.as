package org.farmcode.sodalityLibrary.control.modifiers
{
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.events.IEventDispatcher;

	public class MultiplyModifier extends AbstractNumberModifier
	{
		public var amount:Number;
		
		public function MultiplyModifier(amount:Number){
			this.amount = amount;
		}
		
		override public function inputNumber(value:Number, oldValue:Number):Number{
			if(!isNaN(amount))value *= amount;
			return value;
		}
		
	}
}