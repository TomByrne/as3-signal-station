package org.farmcode.sodalityPlatformEngine.particles
{
	import au.com.thefarmdigital.parallax.Point3D;
	
	import org.farmcode.sodality.TriggerTiming;
	import org.farmcode.sodality.advice.MethodAdvice;
	import org.farmcode.sodality.advisors.DynamicAdvisor;
	import org.farmcode.sodality.triggers.AdviceClassTrigger;
	import org.farmcode.sodalityPlatformEngine.parallax.advice.AddManyParallaxDisplaysAdvice;
	import org.farmcode.sodalityPlatformEngine.scene.advice.AddSceneItemAdvice;
	import org.farmcode.sodalityPlatformEngine.scene.advice.RemoveSceneItemAdvice;
	import org.farmcode.sodalityPlatformEngine.scene.adviceTypes.ISceneRenderAdvice;
	import org.farmcode.sodalityPlatformEngine.structs.items.SimpleItem;
	import org.flintparticles.common.particles.Particle;
	import org.flintparticles.common.renderers.RendererBase;
	import org.flintparticles.common.utils.Maths;
	import org.flintparticles.threeD.particles.Particle3D;
	
	public class ParallaxFlintRenderer extends RendererBase
	{
		private var _renderTrigger: AdviceClassTrigger;
		private var _advisor: DynamicAdvisor;
		protected var cumulative:int = 0;
		protected var pendingParticles: Array = new Array();
		
		public function get advisor(): DynamicAdvisor
		{
			return this._advisor;
		}
		public function set advisor(value: DynamicAdvisor): void
		{
			if (value != this.advisor)
			{
				if (this.advisor != null)
				{
					this.advisor.removeTrigger(this._renderTrigger);
					this._renderTrigger = null;
				}
				
				this._advisor = value;
				
				if (this.advisor != null)
				{
					this._renderTrigger = new AdviceClassTrigger(ISceneRenderAdvice);
					this._renderTrigger.triggerTiming = TriggerTiming.AFTER;
					this._renderTrigger.advice = [new MethodAdvice(this, "onSceneRender")];
					this.advisor.addTrigger(this._renderTrigger);
				}
			}
		}
		
		/**
		 * The addParticle method is called when a particle is added to one of
		 * the emitters that is being rendered by this renderer.
		 * 
		 * @param particle The particle.
		 */
		override protected function addParticle( particle:Particle ):void{
			this.pendingParticles.push(particle);
		}
		
		public function onSceneRender(cause: ISceneRenderAdvice): void
		{
			if (this.pendingParticles.length > 0)
			{
				var newParticles: Array = this.pendingParticles.splice(0);
				var displays: Array = new Array();
				for each (var particle: Particle3D in newParticles)
				{
					var particleSceneItem: ParticleSceneItem = particle.image as ParticleSceneItem;
					if(particleSceneItem == null){
						particleSceneItem = new ParticleSceneItem();
						particleSceneItem.image = particle.image;
						particleSceneItem.image.name = String(cumulative);
						particleSceneItem.particle = particle as Particle3D;
						particle.image = particleSceneItem;
						positionParticle(particle);
					}
					cumulative++;
					displays.push(particleSceneItem.parallaxDisplay);
					//advisor.dispatchEvent(new AddSceneItemAdvice(null, particle.image));
				}
				advisor.dispatchEvent(new AddManyParallaxDisplaysAdvice(displays));
			}
		}
		
		/**
		 * The removeParticle method is called when a particle is removed from one
		 * of the emitters that is being rendered by this renderer.
		 * @param particle The particle.
		 */
		override protected function removeParticle( particle:Particle ):void{
			cumulative--;
			var pendingIndex: int = this.pendingParticles.indexOf(particle);
			if (pendingIndex >= 0)
			{
				this.pendingParticles.splice(pendingIndex, 1);
			}
			else
			{
				advisor.dispatchEvent(new RemoveSceneItemAdvice(null,particle.image));
			}
		}
		
		/**
		 * The renderParticles method is called during the render phase of 
		 * every frame if the state of one of the emitters being rendered
		 * by this renderer has changed.
		 * 
		 * @param particles The particles being managed by all the emitters
		 * being rendered by this renderer. The particles are in no particular
		 * order.
		 */
		override protected function renderParticles( particles:Array ):void{
			for each(var particle:Particle3D in particles){
				if (this.pendingParticles.indexOf(particle) < 0)
				{
					positionParticle(particle);
				}
			}
		}
		protected function positionParticle(particle:Particle3D):void{
			var simpleItem: SimpleItem = particle.image as SimpleItem;
			var oldPos:Point3D = simpleItem.position3D;
			var point:Point3D = Point3D.getNew();
			point.x = particle.position.x;
			point.y = particle.position.y;
			point.z = particle.position.z;
			simpleItem.position3D = point;
			simpleItem.rotation = Maths.asDegrees(particle.rotation.z);
			simpleItem.image.scaleX = simpleItem.image.scaleY = particle.scale;
			if(oldPos){
				oldPos.release();
			}
		}
	}
}