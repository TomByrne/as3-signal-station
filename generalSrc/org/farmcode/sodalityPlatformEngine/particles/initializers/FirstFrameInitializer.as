package org.farmcode.sodalityPlatformEngine.particles.initializers
{
	import flash.events.Event;
	
	import org.flintparticles.common.emitters.Emitter;
	import org.flintparticles.common.events.EmitterEvent;
	import org.flintparticles.common.initializers.Initializer;
	import org.flintparticles.common.initializers.InitializerBase;
	import org.flintparticles.common.particles.Particle;

	public class FirstFrameInitializer extends InitializerBase
	{
		public function get firstInitializer():Initializer{
			return _firstInitializer;
		}
		public function set firstInitializer(value:Initializer):void{
			//if(_firstInitializer != value){
				_firstInitializer = value;
			//}
		}
		public function get otherInitializer():Initializer{
			return _otherInitializer;
		}
		public function set otherInitializer(value:Initializer):void{
			//if(_otherInitializer != value){
				_otherInitializer = value;
			//}
		}
		
		private var _firstInitializer:Initializer;
		private var _otherInitializer:Initializer;
		private var _emitter:Emitter;
		private var _stopped:Boolean = false;
		
		public function FirstFrameInitializer(firstInitializer:Initializer=null){
			super();
			this.firstInitializer = firstInitializer;
		}
		
		override public function initialize( emitter:Emitter, particle:Particle ):void{
			if(_emitter!=emitter){
				if(_emitter)_emitter.addEventListener(EmitterEvent.EMITTER_UPDATED, onEmitterUpdated);
				_emitter = emitter
				emitter.addEventListener(EmitterEvent.EMITTER_UPDATED, onEmitterUpdated);
				_stopped = false;
			}
			if(!_stopped){
				_firstInitializer.initialize( emitter, particle);
			}else if(_otherInitializer){
				_otherInitializer.initialize( emitter, particle);
			}
		}
		protected function onEmitterUpdated(e:Event):void{
			_emitter.addEventListener(EmitterEvent.EMITTER_UPDATED, onEmitterUpdated);
			_stopped = true;
		}
	}
}