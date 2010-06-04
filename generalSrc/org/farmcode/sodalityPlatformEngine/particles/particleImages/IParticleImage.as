package org.farmcode.sodalityPlatformEngine.particles.particleImages
{
	import org.flintparticles.threeD.geom.Vector3D;
	
	public interface IParticleImage
	{
		function set velocity(value:Vector3D):void;
		function render():void;
	}
}