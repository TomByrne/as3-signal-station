package org.farmcode.sodalityPlatformEngine.particles.advice
{
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodalityPlatformEngine.particles.adviceTypes.IRemoveEmitterAdvice;
	
	import org.flintparticles.threeD.emitters.Emitter3D;

	public class RemoveEmitterAdvice extends Advice implements IRemoveEmitterAdvice
	{
		[Property(toString="true",clonable="true")]
		public function get emitter():Emitter3D{
			return _emitter;
		}
		public function set emitter(value:Emitter3D):void{
			_emitter = value;
		}
		
		private var _emitter:Emitter3D;
		
		public function RemoveEmitterAdvice(emitter:Emitter3D=null){
			super();
			this.emitter = emitter;
		}
		
	}
}