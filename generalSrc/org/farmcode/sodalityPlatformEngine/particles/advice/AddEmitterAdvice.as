package org.farmcode.sodalityPlatformEngine.particles.advice
{
	import org.farmcode.sodalityPlatformEngine.particles.adviceTypes.IAddEmitterAdvice;
	
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodalityLibrary.core.adviceTypes.IRevertableAdvice;
	import org.flintparticles.threeD.emitters.Emitter3D;

	public class AddEmitterAdvice extends Advice implements IAddEmitterAdvice, IRevertableAdvice
	{
		[Property(toString="true",clonable="true")]
		public function get emitter():Emitter3D{
			return _emitter;
		}
		public function set emitter(value:Emitter3D):void{
			_emitter = value;
		}
		
		[Property(toString="true",clonable="true")]
		public function get initializers():Array{
			return _initializers;
		}
		public function set initializers(value:Array):void{
			_initializers = value;
		}
		
		[Property(toString="true",clonable="true")]
		public function get actions():Array{
			return _actions;
		}
		public function set actions(value:Array):void{
			_actions = value;
		}
		public function get doRevert():Boolean{
			return true;
		}
		public function get revertAdvice():Advice{
			return new RemoveEmitterAdvice(emitter);
		}
		
		private var _emitter:Emitter3D;
		private var _initializers:Array;
		private var _actions:Array;
		
		public function AddEmitterAdvice(){
			super();
		}
		
	}
}