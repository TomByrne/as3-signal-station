package org.farmcode.sodalityPlatformEngine.particles.particleImages
{
	import au.com.thefarmdigital.display.MovieClipTimeliner;
	
	import flash.display.MovieClip;
	
	import org.flintparticles.threeD.geom.Vector3D;

	public class ParticleMovieClip extends MovieClip implements IParticleImage
	{
		
		public function get velocity():Vector3D{
			return _velocity;
		}
		public function set velocity(value:Vector3D):void{
			_velocity = value;
		}
		
		private var _velocity:Vector3D;
		
		private var _timeliner:MovieClipTimeliner;
		
		public function ParticleMovieClip(){
			super();
			
			_timeliner = new MovieClipTimeliner(this);
		}
		public function render():void{
			if(_velocity.x>0){
				_timeliner.showStopFrameRun("right");
			}else{
				_timeliner.showStopFrameRun("left");
			}
		}
	}
}