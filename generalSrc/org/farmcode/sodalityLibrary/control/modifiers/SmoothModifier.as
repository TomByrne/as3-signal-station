package org.farmcode.sodalityLibrary.control.modifiers
{
	import flash.events.Event;
	
	import org.tbyrne.motion.AtomicMotion;
	import org.tbyrne.motion.AtomicMotionEvent;
	
	public class SmoothModifier extends AbstractNumberModifier
	{
		private var atomicMotion:AtomicMotion
		
		public function SmoothModifier(mass:Number,acceleration:Number,decceleration:Number, rounding:Number=0){
			atomicMotion = new AtomicMotion(mass,acceleration,decceleration);
			atomicMotion.rounding = rounding;
		}
		override public function inputNumber(value:Number, oldValue:Number):Number{
			atomicMotion.removeEventListener(AtomicMotionEvent.VALUE_CHANGE, onMotionChange);
			atomicMotion.destination = value;
			atomicMotion.start();
			value = atomicMotion.value;
			atomicMotion.addEventListener(AtomicMotionEvent.VALUE_CHANGE, onMotionChange);
			return value;
		}
		public function onMotionChange(e:Event):void{
			dispatchEvent(new Event(Event.CHANGE));
		}
	}
}