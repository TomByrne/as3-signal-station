package org.farmcode.sodalityPlatformEngine.physics
{
	import Box2D.Collision.Shapes.b2PolygonDef;
	import Box2D.Collision.b2AABB;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Joints.b2Joint;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2DebugDraw;
	import Box2D.Dynamics.b2World;
	
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	
	import org.farmcode.collections.IIterator;
	import org.farmcode.collections.linkedList.LinkedList;
	import org.farmcode.sodality.advisors.DynamicAdvisor;
	import org.farmcode.sodality.events.AdviceEvent;
	import org.farmcode.sodalityPlatformEngine.physics.adviceTypes.IAddContactListenerAdvice;
	import org.farmcode.sodalityPlatformEngine.physics.adviceTypes.IAddPhysicsSceneItemAdvice;
	import org.farmcode.sodalityPlatformEngine.physics.adviceTypes.IGetBodyAtPointAdvice;
	import org.farmcode.sodalityPlatformEngine.physics.adviceTypes.IRemoveContactListenerAdvice;
	import org.farmcode.sodalityPlatformEngine.physics.adviceTypes.IRemovePhysicsSceneItemAdvice;
	import org.farmcode.sodalityPlatformEngine.physics.adviceTypes.ISetPhysicsDebugAreaAdvice;
	import org.farmcode.sodalityPlatformEngine.physics.contacts.ContactListener;
	import org.farmcode.sodalityPlatformEngine.scene.adviceTypes.ISceneRenderAdvice;
	import org.farmcode.sodalityPlatformEngine.scene.adviceTypes.IShowSceneAdvice;
	
	public class PhysicsAdvisor extends DynamicAdvisor
	{
		private static const MAX_TIME_DIF:Number = 250; // if the framework is getting slow, the render could start doing large steps (slowing it down more)
		
		public function get physicsWorld():b2World{
			return _currentScene?_currentScene.physicsWorld:null;
		}
		public function get physicsDebug():Sprite{
			return _physicsDebug;
		}
		public function set physicsDebug(value:Sprite):void{
			if(value!=_physicsDebug){
				_physicsDebug = value;
				createDebug();
			}
		}
		
		public var timeStep:Number = 1;
		public var stepsPerSecond:Number = 1000;
		
		private var _currentScene:IPhysicsScene;
		private var _physicsDebug:Sprite;
		private var lastTime:Number = 0;
		private var speed:Number = 1;
		private var itemList:LinkedList;
		private var contactListener:ContactListener;
		
		public function PhysicsAdvisor(){
		}
		
		//private var dCount: uint = 2;
		
		[Trigger(triggerTiming="after")]
		public function onSceneRender(cause:ISceneRenderAdvice):void{
			if(physicsWorld) { // && dCount >= 0){
				//dCount--;
				var time:Number = getTimer();
				if(isNaN(lastTime)){
					lastTime = time;
				}
				var stepRatio:Number = stepsPerSecond/1000;
				var stepTime:int = int(Math.min((time-lastTime)*stepRatio,MAX_TIME_DIF)+0.5);
				if(stepTime>0){
					var numSteps: uint = timeStep*speed/stepRatio;
					physicsWorld.Step(numSteps, stepTime);
					lastTime += stepTime / stepRatio;
					var iterator:IIterator = itemList.getIterator();
					var item:IPhysicsItem;
					while(item = iterator.next()){
						item.stepPhysics();
					}
					iterator.release();
				}
			}
		}
		
		[Trigger(triggerTiming="before")]
		public function onDebugChange(cause:ISetPhysicsDebugAreaAdvice):void{
			physicsDebug = cause.debugArea;
		}
		[Trigger(triggerTiming="before")]
		public function onBeforeSceneChange(cause:IShowSceneAdvice):void
		{
			if (this.physicsWorld)
			{
				// some items must be explicitly destroyed
				var iterator:IIterator = itemList.getIterator();
				var physicsItem:IPhysicsItem;
				while(physicsItem = iterator.next()){
					physicsItem.destroyPhysics(physicsWorld);
				}
				iterator.release();
				
				// Destroy bodies
				var bNode: b2Body = this.physicsWorld.GetBodyList();
				while (bNode)
				{
					var b: b2Body = bNode;
					bNode = bNode.GetNext();
					this.physicsWorld.DestroyBody(b);
				}
				
				// Destroy joints
				var jNode: b2Joint = this.physicsWorld.GetJointList();
				while (jNode)
				{
					var j: b2Joint = jNode;
					jNode = jNode.GetNext();
					this.physicsWorld.DestroyJoint(j);
				}
				this.physicsWorld.SetDebugDraw(null);
				_currentScene.physicsWorld = null;
				_currentScene = null;
				
				contactListener.destroy();
				contactListener = null;
				itemList.release();
				itemList = null;
			}
			
			itemList = LinkedList.getNew();
			cause.addEventListener(AdviceEvent.CONTINUE, onSceneChange);
		}
		public function onSceneChange(e:AdviceEvent):void
		{
			var cause:IShowSceneAdvice = (e.target as IShowSceneAdvice);
			if(cause.sceneDetails.scene && cause.sceneDetails.scene is IPhysicsScene)
			{
				var wallWidth:Number = 100;
				
				_currentScene = cause.sceneDetails.scene as IPhysicsScene;
				
				speed = (isNaN(_currentScene.physicsSpeed)?1:_currentScene.physicsSpeed);
				var bounds:Rectangle = _currentScene.physicsBounds;
				var scale:Number = _currentScene.physicsScale;
				var worldBounds:b2AABB = new b2AABB();
				worldBounds.lowerBound.Set((bounds.x-wallWidth)*scale,(bounds.y-wallWidth)*scale);
				worldBounds.upperBound.Set((bounds.x+bounds.width+wallWidth)*scale,(bounds.y+bounds.height+wallWidth)*scale);
				_currentScene.physicsWorld = new b2World(worldBounds,new b2Vec2(0,_currentScene.physicsGravity*scale),true);
				_currentScene.physicsWorld.SetWarmStarting(true);
				_currentScene.physicsWorld.SetPositionCorrection(true);
				
				contactListener = new ContactListener();
				_currentScene.physicsWorld.SetContactListener(contactListener);
				
				createDebug();
				
				var wallSd:b2PolygonDef = new b2PolygonDef();
				var wallBd:b2BodyDef = new b2BodyDef();
				var wallB:b2Body;
				// Top
				wallBd.position.Set((bounds.x+bounds.width/2)*scale, (bounds.y-wallWidth/2)*scale);
				wallSd.SetAsBox((bounds.width/2+wallWidth)*scale, (wallWidth/2)*scale);
				wallSd.density = 0;
				wallB = _currentScene.physicsWorld.CreateBody(wallBd);
				wallB.CreateShape(wallSd);
				wallB.SetMassFromShapes();
				// Bottom
				wallBd.position.Set((bounds.x+bounds.width/2)*scale, (bounds.y+(bounds.height+wallWidth/2))*scale);
				wallB = _currentScene.physicsWorld.CreateBody(wallBd);
				wallB.CreateShape(wallSd);
				wallB.SetMassFromShapes();
				
				// Left
				wallBd.position.Set((bounds.x-wallWidth/2)*scale , (bounds.y+bounds.height/2)*scale);
				wallSd.SetAsBox((wallWidth/2)*scale, (bounds.height/2+wallWidth)*scale);
				wallSd.density = 0;
				wallB = _currentScene.physicsWorld.CreateBody(wallBd);
				wallB.CreateShape(wallSd);
				wallB.SetMassFromShapes();
				// Right
				wallBd.position.Set((bounds.x+bounds.width+wallWidth/2)*scale, (bounds.y+bounds.height/2)*scale);
				wallB = _currentScene.physicsWorld.CreateBody(wallBd);
				wallB.CreateShape(wallSd);
				wallB.SetMassFromShapes();
				
				var iterator:IIterator = itemList.getIterator();
				var physicsItem:IPhysicsItem;
				while(physicsItem = iterator.next()){
					physicsItem.createPhysics(physicsWorld, _currentScene.physicsScale);
				}
				iterator.release();
				
			}
			lastTime = NaN;
			//advice.adviceContinue();
		}
		
		[Trigger(triggerTiming="after")]
		public function onAddItem(cause: IAddPhysicsSceneItemAdvice):void{
			if(cause.addToScene){
				var physicsItem:IPhysicsItem = (cause.sceneItem as IPhysicsItem);
				if(physicsItem.addToPhysics){
					if(physicsWorld)physicsItem.createPhysics(physicsWorld, _currentScene.physicsScale);
					itemList.unshift(physicsItem);
				}
			}
		}
		[Trigger(triggerTiming="after")]
		public function onRemoveItem(cause: IRemovePhysicsSceneItemAdvice):void{
			if(physicsWorld){
				var physicsItem:IPhysicsItem = (cause.sceneItem as IPhysicsItem);
				if(itemList.removeFirst(physicsItem)){
					physicsItem.destroyPhysics(physicsWorld);
				}
			}
		}
		[Trigger(triggerTiming="after")]
		public function onGetBodyAtMouse(cause: IGetBodyAtPointAdvice):void{
			if(physicsWorld){
				cause.bodyAtPoint = getBodyAtPoint(cause.worldPoint, cause.includeStatic);
			}
		}
		[Trigger(triggerTiming="after")]
		public function onAddContactListener(cause: IAddContactListenerAdvice):void{
			if(contactListener){
				contactListener.addContactListener(cause.contactHandler,cause.contactBodies);
			}
		}
		[Trigger(triggerTiming="after")]
		public function onRemoveContactListener(cause: IRemoveContactListenerAdvice):void{
			if(contactListener){
				contactListener.removeContactListener(cause.contactHandler,cause.contactBodies);
			}
		}
		protected function createDebug():void{
			if(_currentScene && _currentScene.physicsWorld){
				if(_physicsDebug){
					var debugDraw:b2DebugDraw = new b2DebugDraw();
					debugDraw.SetSprite(_physicsDebug);
	                debugDraw.SetFillAlpha(0);
	                debugDraw.SetLineThickness(1.0);
	                debugDraw.SetFlags(b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit);
	                debugDraw.SetDrawScale(1/_currentScene.physicsScale);
	                _currentScene.physicsWorld.SetDebugDraw(debugDraw);
				}else{
					_currentScene.physicsWorld.SetDebugDraw(null);
				}
			}
		}
		protected function getBodyAtPoint(point:Point, includeStatic:Boolean=false):b2Body{
			// Make a small box.
			var scale:Number = _currentScene.physicsScale;
			var mousePVec:b2Vec2 = new b2Vec2(point.x*scale, point.y*scale);
			var aabb:b2AABB = new b2AABB();
			aabb.lowerBound.Set(point.x - 0.01*scale, point.y - 0.01*scale);
			aabb.upperBound.Set(point.x + 0.01*scale, point.y + 0.01*scale);
			
			// Query the world for overlapping shapes.
			var k_maxCount:int = 10;
			var shapes:Array = new Array();
			var count:int = physicsWorld.Query(aabb, shapes, k_maxCount);
			var body:b2Body = null;
			for (var i:int = 0; i < count; ++i)
			{
				if (shapes[i].m_body.IsStatic() == false || includeStatic)
				{
					var inside:Boolean = shapes[i].TestPoint(mousePVec);
					if (inside)
					{
						body = shapes[i].m_body;
						break;
					}
				}
			}
			return body;
		}
	}
}