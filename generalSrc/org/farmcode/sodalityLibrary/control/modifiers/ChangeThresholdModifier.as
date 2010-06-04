package org.farmcode.sodalityLibrary.control.modifiers
{
	import flash.events.Event;
	
	/**
	 * Applies the nested modifier only if the change in value is above a certain amount.
	 */
	public class ChangeThresholdModifier extends AbstractNumberModifier
	{
		
		public function get nestedModifier():INumberModifier{
			return _nestedModifier;
		}
		public function set nestedModifier(value:INumberModifier):void{
			if(_nestedModifier != value){
				if(_nestedModifier){
					_nestedModifier.removeEventListener(Event.CHANGE, onNestedChange);
				}
				_nestedModifier = value;
				if(_nestedModifier){
					_nestedModifier.addEventListener(Event.CHANGE, onNestedChange);
				}
			}
		}
		
		private var _nestedModifier:INumberModifier;
		private var _changePending:Boolean;
		private var _active:Boolean;
		
		public var changeThreshold:Number;
		public var invert:Boolean;
		
		public function ChangeThresholdModifier(changeThreshold:Number = 1, invert:Boolean = false, nestedModifier:INumberModifier=null){
			super();
			this.changeThreshold = changeThreshold;
			this.invert = invert;
			this.nestedModifier = nestedModifier;
		}
		
		override public function inputNumber(value:Number, oldValue:Number):Number{
			var ret:Number = nestedModifier.input(value, oldValue); // should always input numbers into nested modifier in case it needs to keep up.
			var above:Boolean = Math.abs(value-oldValue)>changeThreshold;
			if(_changePending || (above && !invert) || (!above && invert)){
				_active = true;
				_changePending = false;
				return ret;
			}else{
				_active = false;
				return value;
			}
		}
		protected function onNestedChange(e:Event):void{
			if(_active){
				_changePending = true;
				dispatchEvent(new Event(Event.CHANGE));
			}
		}
	}
}