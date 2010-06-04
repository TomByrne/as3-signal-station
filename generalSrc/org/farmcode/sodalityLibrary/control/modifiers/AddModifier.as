package org.farmcode.sodalityLibrary.control.modifiers
{
	import flash.events.Event;

	public class AddModifier extends AbstractNumberModifier
	{
		private var _amount:Number;
		
		public function AddModifier(amount:Number){
			this.amount = amount;
		}
		
		public function set amount(value: Number): void
		{
			if (value != this.amount)
			{
				this._amount = value;
				this.dispatchEvent(new Event(Event.CHANGE));
			}
		}
		public function get amount(): Number
		{
			return this._amount;
		}
		
		override public function inputNumber(value:Number, oldValue:Number):Number{
			if(!isNaN(amount))value += amount;
			return value;
		}
		
	}
}