package org.farmcode.sodalityPlatformEngine.particles
{
	import org.farmcode.sodalityPlatformEngine.particles.particleImages.IParticleImage;
	import org.farmcode.sodalityPlatformEngine.scene.adviceTypes.ISceneRenderAdvice;
	import org.farmcode.sodalityPlatformEngine.structs.items.SimpleItem;
	
	import flash.display.DisplayObject;
	
	import org.farmcode.sodality.TriggerTiming;
	import org.farmcode.sodality.advice.MethodAdvice;
	import org.farmcode.sodality.advisors.IDynamicAdvisor;
	import org.farmcode.sodality.triggers.AdviceClassTrigger;
	import org.flintparticles.threeD.particles.Particle3D;

	public class ParticleSceneItem extends SimpleItem implements IDynamicAdvisor
	{
		public function get particle():Particle3D{
			return _particle;
		}
		public function set particle(value:Particle3D):void{
			//if(_particle!=value){
				_particle = value;
			//}
		}
		override public function set image(value:DisplayObject):void{
			super.image = value;
			_particleImage = (value as IParticleImage);
			if(_particleImage){
				if(!isAdvisor){
					isAdvisor = true;
					_dynamicAdvisor.addTrigger(new AdviceClassTrigger(ISceneRenderAdvice,[new MethodAdvice(this,"onSceneRender")],TriggerTiming.AFTER));
				}
			}else{
				isAdvisor = false;
			}
		}
		
		public function get triggers():Array{
			return _dynamicAdvisor.triggers;
		}
		public function set triggers(value:Array):void{
			_dynamicAdvisor.triggers = value;
		}
		
		private var _particle:Particle3D;
		private var _particleImage:IParticleImage;
		
		public function ParticleSceneItem(particle:Particle3D=null){
			super();
			this.particle = particle;
		}
		public function onSceneRender(cause:ISceneRenderAdvice):void{
			if(_particle && _particleImage){
				_particleImage.velocity = _particle.velocity;
				_particleImage.render();
			}
		}
	}
}