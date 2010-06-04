package org.farmcode.sodalityPlatformEngine.particles
{
	import au.com.thefarmdigital.parallax.Point3D;
	import au.com.thefarmdigital.parallax.modifiers.ParallaxCamera;
	import org.farmcode.sodalityPlatformEngine.core.advice.RequestApplicationSizeAdvice;
	import org.farmcode.sodalityPlatformEngine.core.adviceTypes.IApplicationResizeAdvice;
	import org.farmcode.sodalityPlatformEngine.particles.adviceTypes.IAddEmitterAdvice;
	import org.farmcode.sodalityPlatformEngine.particles.adviceTypes.IAddSceneEmitterAdvice;
	import org.farmcode.sodalityPlatformEngine.particles.adviceTypes.IRemoveEmitterAdvice;
	import org.farmcode.sodalityPlatformEngine.particles.counters.CounterGroup;
	import org.farmcode.sodalityPlatformEngine.particles.initializers.FirstFrameInitializer;
	import org.farmcode.sodalityPlatformEngine.particles.zones.ParallaxFrustrumZone;
	import org.farmcode.sodalityPlatformEngine.scene.adviceTypes.IDisposeSceneAdvice;
	import org.farmcode.sodalityPlatformEngine.scene.adviceTypes.ISceneRenderAdvice;
	import org.farmcode.sodalityPlatformEngine.scene.adviceTypes.IShowSceneAdvice;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	import org.farmcode.sodality.advisors.DynamicAdvisor;
	import org.farmcode.sodality.events.AdviceEvent;
	import org.flintparticles.common.actions.Action;
	import org.flintparticles.common.counters.Blast;
	import org.flintparticles.common.counters.Steady;
	import org.flintparticles.common.initializers.ImageClass;
	import org.flintparticles.common.initializers.Initializer;
	import org.flintparticles.threeD.actions.BoundingBox;
	import org.flintparticles.threeD.actions.DeathZone;
	import org.flintparticles.threeD.actions.Move;
	import org.flintparticles.threeD.emitters.Emitter3D;
	import org.flintparticles.threeD.initializers.Position;
	import org.flintparticles.threeD.zones.Zone3D;

	public class ParticleAdvisor extends DynamicAdvisor
	{
		override public function set addedToPresident(value:Boolean):void{
			super.addedToPresident = value;
			if(value){
				getSize();
			}
		}
		
		public var parallaxCamera:ParallaxCamera;
		
		protected var renderer:ParallaxFlintRenderer = new ParallaxFlintRenderer();
		protected var emitters:Dictionary = new Dictionary();
		protected var lastTime:Number;
		protected var particleScene:IParticleScene;
		protected var _active:Boolean;
		protected var _pendingSceneEmitters:Array = [];
		protected var _sceneBounds:Rectangle;
		protected var frustrumPadding:Number = 0;
		protected var _screenBounds:Rectangle = new Rectangle();
		
		protected var moveAction:Move;
		protected var deathZone:ParallaxFrustrumZone;
		protected var deathZoneAction:DeathZone;
		
		public function ParticleAdvisor(){
			super();
			renderer.advisor = this;
			moveAction = new Move();
		}
		

		[Trigger(triggerTiming="after")]
		public function onAddSceneEmitter(cause:IAddSceneEmitterAdvice):void{
			if(particleScene){
				addSceneEmitter(cause);
			}else{
				_pendingSceneEmitters.push(cause.cloneAdvice());
			}
		}
		[Trigger(triggerTiming="after")]
		public function onAddEmitter(cause:IAddEmitterAdvice):void{
			if(cause.emitter){
				addEmitter(cause.emitter, cause.initializers, cause.actions);
			}
		}
		[Trigger(triggerTiming="after")]
		public function onRemoveEmitter(cause:IRemoveEmitterAdvice):void{
			removeEmitter(cause.emitter);
		}
		[Trigger(triggerTiming="before")]
		public function onSceneDisposal(cause:IDisposeSceneAdvice):void{
			for(var i:* in emitters){
				removeEmitter(i as Emitter3D);
			}
			_active = false;
			particleScene = null;
			deathZoneAction = null;
			deathZone = null;
			frustrumPadding = 0;
		}
		[Trigger(triggerTiming="after")]
		public function onAfterSceneChange(cause:IShowSceneAdvice):void{
			lastTime = getTimer();
			var cast:IParticleScene = (cause.sceneDetails.scene as IParticleScene);
			if(cast && cast.cameraBounds){
				_active = true;
				particleScene = cast;
				_sceneBounds = particleScene.cameraBounds.clone();
				
				if(!isNaN(particleScene.frustumDeathPadding)){
					frustrumPadding = particleScene.frustumDeathPadding;
					_sceneBounds.x -= frustrumPadding;
					_sceneBounds.width += frustrumPadding; // multiplying by 2 destroys negatives
					_sceneBounds.width += frustrumPadding;
						
					_sceneBounds.y -= frustrumPadding;
					_sceneBounds.height += frustrumPadding;
					_sceneBounds.height += frustrumPadding;
					
					if(!isNaN(particleScene.frustumDeathFarDistance)){
						deathZone = new ParallaxFrustrumZone();
						commitBoundsToDeath();
						deathZoneAction = new DeathZone(deathZone,true);
						
						for (var i:* in emitters){
							var emitter:Emitter3D = (i as Emitter3D);
							emitter.addAction(deathZoneAction);
						}
					}
					for each(var advice:IAddSceneEmitterAdvice in _pendingSceneEmitters){
						addSceneEmitter(advice);
					}
					_pendingSceneEmitters = [];
				}else{
					frustrumPadding = 0;
				}
			}
		}
		[Trigger(triggerTiming="after")]
		public function onSceneRender(cause:ISceneRenderAdvice):void{
			if(_active){
				if(isNaN(lastTime))lastTime = getTimer();
				var time:Number = getTimer();
				for (var emitter:* in emitters){
					var cast:Emitter3D = (emitter as Emitter3D);
					cast.update(time-lastTime);
				}
				lastTime = time;
			}
		}
		
		protected function addEmitter(emitter:Emitter3D, initializers:Array, actions:Array):void{
			if(!emitters[emitter]){
				_active = true;
				renderer.addEmitter(emitter);
				emitters[emitter] = true;
				emitter.useInternalTick = false;
				for each(var initializer:Initializer in initializers){
					emitter.addInitializer(initializer);
				}
				for each(var action:Action in actions){
					emitter.addAction(action);
				}
				emitter.addAction(moveAction);
				if(deathZoneAction)emitter.addAction(deathZoneAction);
				emitter.start();
			}
		}
		protected function removeEmitter(emitter:Emitter3D):void{
			if(emitters[emitter]){
				delete emitters[emitter];
				emitter.stop();
				renderer.removeEmitter(emitter);
				
				if(!particleScene){
					var last:Boolean = true;
					for (var i:* in emitters){
						last = false;
						break;
					}
					if(last){
						_active = false;
					}
				}
				if(deathZoneAction)emitter.removeAction(deathZoneAction);
				emitter.removeAction(moveAction);
			}
		}
		protected function addSceneEmitter(advice:IAddSceneEmitterAdvice):void{
			var nearDistance:Number = advice.nearDistance;
			if(isNaN(nearDistance) || nearDistance<0)nearDistance = 0;
			var farDistance:Number = advice.farDistance;
			if((isNaN(farDistance) || farDistance<nearDistance) && !isNaN(particleScene.frustumDeathFarDistance)){
				farDistance = particleScene.frustumDeathFarDistance;
			}
			
			var nearRectangle:Rectangle = getSlice(nearDistance, advice.minX, advice.maxX, advice.minY, advice.maxY);
			var farRectangle:Rectangle = getSlice(farDistance, advice.minX, advice.maxX, advice.minY, advice.maxY);
			var frustrumZone:ParallaxFrustrumZone = new ParallaxFrustrumZone(nearDistance,nearRectangle,farDistance,farRectangle);
			
			var posInitialiser:FirstFrameInitializer = new FirstFrameInitializer();
			var counters:Array = [];
			
			if(!isNaN(advice.initialFill) && advice.initialFill){
				posInitialiser.firstInitializer = new Position(frustrumZone);
				counters.push(new Blast(advice.initialFill));
			}
			if(!isNaN(advice.fillRate) && advice.fillEdge){
				var zone:Zone3D;
				switch(advice.fillEdge){
					case ParticleSceneEdges.TOP:
						zone = frustrumZone.topEdge;
						break;
					case ParticleSceneEdges.LEFT:
						zone = frustrumZone.leftEdge;
						break;
					case ParticleSceneEdges.RIGHT:
						zone = frustrumZone.rightEdge;
						break;
					case ParticleSceneEdges.BOTTOM:
						zone = frustrumZone.bottomEdge;
						break;
					default:
						throw new Error("The fillEdge property must match one of the constants within the ParticleSceneEdges class");
				}
				posInitialiser.otherInitializer = new Position(zone);
				counters.push(new Steady(advice.fillRate));
			}
			var emitter:Emitter3D = new Emitter3D();
			emitter.addInitializer(posInitialiser);
			emitter.counter = new CounterGroup(counters);
			emitter.addInitializer(new ImageClass(advice.particleImageClass));
			
			if(advice.doBounding){
				emitter.addAction(new BoundingBox(nearRectangle.left,nearRectangle.right,nearRectangle.top,nearRectangle.bottom,nearDistance,farDistance));
			}
			
			addEmitter(emitter, advice.initializers, advice.actions);
		}
		protected function getSlice(distance:Number, minX:Number=NaN, maxX:Number=NaN, minY:Number=NaN, maxY:Number=NaN):Rectangle{
			
			var centerX:Number = (_screenBounds.width/2)+frustrumPadding;
			var centerY:Number = (_screenBounds.height/2)+frustrumPadding;
			
			var topLeft:Point3D = parallaxCamera.translate2Dto3D(new Point(-centerX,-centerY),distance);
			var bottomRight:Point3D = parallaxCamera.translate2Dto3D(new Point(centerX,centerY),distance);
			topLeft.x += _sceneBounds.left;
			topLeft.y += _sceneBounds.top;
			bottomRight.x += _sceneBounds.right;
			bottomRight.y += _sceneBounds.bottom;
			
			var ret:Rectangle = new Rectangle(topLeft.x,topLeft.y,bottomRight.x-topLeft.x,bottomRight.y-topLeft.y);
			
			if(!isNaN(minX) && ret.left<minX)ret.left = minX;
			if(!isNaN(minY) && ret.top<minY)ret.top = minY;
			if(!isNaN(maxX) && ret.right>maxX)ret.right = maxX;
			if(!isNaN(maxY) && ret.bottom>maxY)ret.bottom = maxY;
			
			return ret;
		}
		protected function getSize():void{
			var getAppSize:RequestApplicationSizeAdvice = new RequestApplicationSizeAdvice();
			getAppSize.addEventListener(AdviceEvent.COMPLETE, onSizeRetrieved);
			dispatchEvent(getAppSize);
		}
		protected function onSizeRetrieved(e:AdviceEvent):void{
			var getAppSize:RequestApplicationSizeAdvice = (e.target as RequestApplicationSizeAdvice);
			_screenBounds = getAppSize.appBounds;
			commitBoundsToDeath();
		}
		[Trigger(triggerTiming="after")]
		public function onAppResize(cause: IApplicationResizeAdvice):void{
			_screenBounds = cause.appBounds;
			commitBoundsToDeath();
		}
		protected function commitBoundsToDeath():void{
			if(deathZone){
				var nearRectangle:Rectangle = getSlice(0);
				var farRectangle:Rectangle = getSlice(particleScene.frustumDeathFarDistance);
				deathZone.nearDistance = 0;
				deathZone.nearRectangle = nearRectangle
				deathZone.farDistance = particleScene.frustumDeathFarDistance
				deathZone.farRectangle = farRectangle;
			}
		}
	}
}