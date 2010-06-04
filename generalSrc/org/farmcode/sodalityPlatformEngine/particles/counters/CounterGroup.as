package org.farmcode.sodalityPlatformEngine.particles.counters
{
	import org.flintparticles.common.counters.Counter;
	import org.flintparticles.common.emitters.Emitter;

	public class CounterGroup implements Counter
	{
		public function get counters():Array{
			return _counters;
		}
		public function set counters(value:Array):void{
			_counters = value;
		}
		
		private var _counters:Array;
		
		public function CounterGroup(counters:Array = null){
			_counters = counters?counters:[];
		}

		public function startEmitter(emitter:Emitter):uint{
			var ret:uint = 0;
			for each(var counter:Counter in _counters){
				ret += counter.startEmitter(emitter);
			}
			return ret;
		}
		
		public function updateEmitter(emitter:Emitter, time:Number):uint{
			var ret:uint = 0;
			for each(var counter:Counter in _counters){
				ret += counter.updateEmitter(emitter, time);
			}
			return ret;
		}
		
		public function stop():void{
			for each(var counter:Counter in _counters){
				counter.stop();
			}
		}
		
		public function resume():void{
			for each(var counter:Counter in _counters){
				counter.resume();
			}
		}
	}
}