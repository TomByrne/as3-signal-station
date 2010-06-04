package org.farmcode.sodalityPlatformEngine.particles.adviceTypes
{
	import org.farmcode.sodality.advice.IAdvice;
	
	import org.flintparticles.threeD.emitters.Emitter3D;
	
	public interface IAddEmitterAdvice extends IAdvice
	{
		function get emitter():Emitter3D;
		function get initializers():Array;
		function get actions():Array;
	}
}