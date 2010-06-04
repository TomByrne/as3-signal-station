package org.farmcode.sodalityPlatformEngine.particles.adviceTypes
{
	import org.farmcode.sodality.advice.IAdvice;
	import org.flintparticles.threeD.emitters.Emitter3D;
	
	public interface IAddSceneEmitterAdvice extends IAdvice
	{
		/**
		 * These values are in relation to the scene's bounds
		 */
		function get minX():Number;
		function get maxX():Number;
		function get minY():Number;
		function get maxY():Number;
		function get nearDistance():Number;
		function get farDistance():Number;
		
		/**
		 * This should match a value from org.farmcode.sodalityPlatformEngine.particles.ParticleSceneEdges
		 */
		function get fillEdge():String;
		function get fillRate():Number;
		
		function get initialFill():Number;
		
		function get particleImageClass():Class;
		
		function get initializers():Array;
		function get actions():Array;
		
		function get doBounding():Boolean;
	}
}