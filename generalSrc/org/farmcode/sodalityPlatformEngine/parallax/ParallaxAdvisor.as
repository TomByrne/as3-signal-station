package org.farmcode.sodalityPlatformEngine.parallax
{
	import au.com.thefarmdigital.parallax.IParallaxDisplay;
	import au.com.thefarmdigital.parallax.LayeredParallax;
	import au.com.thefarmdigital.parallax.Parallax;
	import au.com.thefarmdigital.parallax.Point3D;
	import au.com.thefarmdigital.utils.FunctionCall;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.farmcode.collections.IIterator;
	import org.farmcode.collections.linkedList.LinkedList;
	import org.farmcode.queueing.ThreadedQueue;
	import org.farmcode.queueing.queueItems.functional.MethodCallQI;
	import org.farmcode.sodality.advisors.DynamicAdvisor;
	import org.farmcode.sodality.events.AdviceErrorEvent;
	import org.farmcode.sodality.events.AdviceEvent;
	import org.farmcode.sodalityPlatformEngine.core.advice.RequestApplicationSizeAdvice;
	import org.farmcode.sodalityPlatformEngine.core.adviceTypes.IApplicationResizeAdvice;
	import org.farmcode.sodalityPlatformEngine.parallax.adviceTypes.IAddManyParallaxDisplaysAdvice;
	import org.farmcode.sodalityPlatformEngine.parallax.adviceTypes.IChangeCameraSettingsAdvice;
	import org.farmcode.sodalityPlatformEngine.parallax.adviceTypes.IConvertParallaxPointAdvice;
	import org.farmcode.sodalityPlatformEngine.parallax.adviceTypes.IConvertScreenPointAdvice;
	import org.farmcode.sodalityPlatformEngine.parallax.adviceTypes.IModifyParallaxItemAdvice;
	import org.farmcode.sodalityPlatformEngine.parallax.adviceTypes.IRemoveManyParallaxDisplaysAdvice;
	import org.farmcode.sodalityPlatformEngine.scene.IScene;
	import org.farmcode.sodalityPlatformEngine.scene.adviceTypes.IAddSceneItemAdvice;
	import org.farmcode.sodalityPlatformEngine.scene.adviceTypes.IDisposeSceneAdvice;
	import org.farmcode.sodalityPlatformEngine.scene.adviceTypes.IRemoveSceneItemAdvice;
	import org.farmcode.sodalityPlatformEngine.scene.adviceTypes.ISceneRenderAdvice;
	import org.farmcode.sodalityPlatformEngine.scene.adviceTypes.IShowSceneAdvice;
	
	public class ParallaxAdvisor extends DynamicAdvisor
	{
		public function get container():DisplayObjectContainer{
			return _container;
		}
		public function set container(value:DisplayObjectContainer):void{
			if(_container){
				_container.removeChild(_parallax.container);
			}
			_container = value;
			if(_container){
				_container.addChild(_parallax.container);
				if(_bounds)sizeParallax();
				else getSize();
			}
		}
		public function get parallax():Parallax{
			return _parallax;
		}
		
		protected var _container:DisplayObjectContainer;
		protected var _parallax:Parallax;
		protected var _currentScene:IParallaxScene;
		protected var _itemsList:LinkedList;
		protected var _bounds:Rectangle;
		protected var _localBounds:Rectangle;
		protected var _queue: ThreadedQueue;
		
		public function ParallaxAdvisor(){
			// TODO: Assign thread id
			this._queue = new ThreadedQueue(null, 0.5);
			_itemsList = LinkedList.getNew();
			_parallax = new LayeredParallax();
			_parallax.doMask = false;
			_parallax.autoRender = false;
			_parallax.container = new Sprite();
		}
		[Trigger(triggerTiming="before")]
		public function onDisposeScene(cause:IDisposeSceneAdvice):void{
			_itemsList.release();
			_itemsList = LinkedList.getNew();
			_parallax.removeAllChildren();
		}
		[Trigger(triggerTiming="after")]
		public function onAfterSceneChange(cause:IShowSceneAdvice):void{
			setScene(cause.sceneDetails.scene);
		}
		
		[Trigger(triggerTiming="after")]
		public function onSceneRender(cause:ISceneRenderAdvice):void{
			_parallax.render();
		}
		
		[Trigger(triggerTiming="after")]
		public function handleCameraChange(cause: IChangeCameraSettingsAdvice): void{
			if(!isNaN(cause.cameraSettings.x))this._parallax.camera.x = cause.cameraSettings.x;
			if(!isNaN(cause.cameraSettings.y))this._parallax.camera.y = cause.cameraSettings.y;
			if(!isNaN(cause.cameraSettings.z))this._parallax.camera.z = cause.cameraSettings.z;
			if(!isNaN(cause.cameraSettings.fieldOfView))this._parallax.camera.fieldOfView = cause.cameraSettings.fieldOfView;
		}
		
		[Trigger(triggerTiming="after")]
		public function onAddItem(cause: IAddSceneItemAdvice):void{
			if(cause.addToScene){
				var parallaxItem:IParallaxItem = cause.sceneItem as IParallaxItem;
				if(parallaxItem){
					if(_itemsList.firstIndexOf(parallaxItem) >= 0){
						throw new Error("ParallaxAdvisor.onAddItem: item has already been added");
					}
					_itemsList.unshift(parallaxItem);
					addItemToParallax(parallaxItem)
				}
			}
		}
		[Trigger(triggerTiming="after")]
		public function onAddManyDisplays(cause:IAddManyParallaxDisplaysAdvice):void{
			for each(var parallaxDisplay:IParallaxDisplay in cause.parallaxDisplays){
				this._queue.addQueueItem(MethodCallQI.getNew(_parallax.addChild, [parallaxDisplay]));
			}
		}
		[Trigger(triggerTiming="after")]
		public function onRemoveItem(cause: IRemoveSceneItemAdvice):void
		{
			var parallaxItem:IParallaxItem = cause.sceneItem as IParallaxItem;
			if(parallaxItem)
			{
				_itemsList.removeFirst(parallaxItem)
				this._queue.addQueueItem(MethodCallQI.getNew(_parallax.removeChild, [parallaxItem.parallaxDisplay]));
			}
		}
		[Trigger(triggerTiming="after")]
		public function onRemoveManyDisplays(cause: IRemoveManyParallaxDisplaysAdvice):void{
			for each(var parallaxDisplay:IParallaxDisplay in cause.parallaxDisplays){
				this._queue.addQueueItem(MethodCallQI.getNew(_parallax.removeChild, [parallaxDisplay]));
			}
		}
		
		[Trigger(triggerTiming="before")]
		public function onConvertParallaxPoint(cause: IConvertParallaxPointAdvice):void{
			var clone:Point3D = cause.parallaxPoint.clone();
			var results:Point3D = _parallax.camera.getPointAndScale(clone);
			cause.screenPoint = _parallax.container.localToGlobal(new Point(results.x,results.y));
			cause.screenDepth = results.z;
			clone.release();
			results.release();
		}
		[Trigger(triggerTiming="before")]
		public function onConvertScreenPoint(cause: IConvertScreenPointAdvice):void{
			var depth:Number = (isNaN(cause.screenDepth)?getDepthAtGlobal(cause.screenPoint):cause.screenDepth);
			if(!isNaN(depth)){
				var localPoint:Point = _parallax.container.globalToLocal(cause.screenPoint);
				cause.parallaxPoint = Point3D.getNew(_parallax.camera.x+localPoint.x,_parallax.camera.y+localPoint.y,depth+_parallax.camera.z);
				cause.addEventListener(AdviceEvent.COMPLETE, onConvertScreenComplete);
			}
		}
		protected function onConvertScreenComplete(e:AdviceErrorEvent):void{
			var cause:IConvertScreenPointAdvice = (e.target as IConvertScreenPointAdvice);
			cause.removeEventListener(AdviceEvent.COMPLETE, onConvertScreenComplete);
			cause.parallaxPoint.release();
		}
		protected function addItemToParallax(parallaxItem:IParallaxItem):void{
			this._queue.addQueueItem(MethodCallQI.getNew(_parallax.addChild, [parallaxItem.parallaxDisplay]));
		}
		protected function getDepthAtGlobal(globalPoint:Point):Number{
			if(_parallax.container.hitTestPoint(globalPoint.x,globalPoint.y,true)){
				var closest:IParallaxDisplay;
				
				var iterator:IIterator = _itemsList.getIterator();
				var parallaxItem:IParallaxItem;
				while(parallaxItem = iterator.next()){
					if(parallaxItem.parallaxDisplay.cameraDepth>0/* && _parallax.isChild(parallaxItem.parallaxDisplay)*/){
						if(!closest || closest.cameraDepth>parallaxItem.parallaxDisplay.cameraDepth){
							if(parallaxItem.parallaxDisplay.display.hitTestPoint(globalPoint.x,globalPoint.y,true)){
								closest = parallaxItem.parallaxDisplay;
							}
						}
					}
				}
				iterator.release();
				
				return closest.cameraDepth;
			}
			return NaN;
			
		}
		protected function setScene(scene:IScene):void{
			if(scene!=_currentScene){
				var parallaxScene:IParallaxScene = (scene as IParallaxScene)
				if(parallaxScene){
					_currentScene = parallaxScene;
				}
			}
		}
		protected function getSize():void{
			var getAppSize:RequestApplicationSizeAdvice = new RequestApplicationSizeAdvice();
			getAppSize.addEventListener(AdviceEvent.COMPLETE, onSizeRetrieved);
			dispatchEvent(getAppSize);
		}
		protected function onSizeRetrieved(e:AdviceEvent):void{
			var getAppSize:RequestApplicationSizeAdvice = (e.target as RequestApplicationSizeAdvice);
			_bounds = getAppSize.appBounds;
			sizeParallax();
		}
		[Trigger(triggerTiming="after")]
		public function onAppResize(cause: IApplicationResizeAdvice):void{
			_bounds = cause.appBounds;
			sizeParallax();
		}
		protected function sizeParallax():void{
			if(_bounds && _container){
				var localPos:Point = _container.globalToLocal(new Point(_bounds.x,_bounds.y));
				if(_parallax.doMask){
					_parallax.container.x = localPos.x;
					_parallax.container.y = localPos.y;
				}else{
					_parallax.container.x = localPos.x+_bounds.width/2;
					_parallax.container.y = localPos.y+_bounds.height/2;
				}
				_parallax.width = _bounds.width;
				_parallax.height = _bounds.height;
				_localBounds = new Rectangle(localPos.x,localPos.y,_bounds.width,_bounds.height);
			}
		}
		
		[Trigger(triggerTiming="before")]
		public function handleModifyParallaxItem(cause: IModifyParallaxItemAdvice): void{
			cause.addEventListener(AdviceEvent.CONTINUE, FunctionCall.create(this.applyItemModify, [cause]));
		}
		
		protected function applyItemModify(advice: IModifyParallaxItemAdvice): void
		{
			var item: IParallaxItem = advice.item;
			var pointChange:Boolean = false;
			var point:Point3D = item.position3D.clone();
			if (!isNaN(advice.x)){
				point.x = advice.x;
				pointChange = true;
			}
			if (!isNaN(advice.y)){
				point.y = advice.y;
				pointChange = true;
			}
			if (!isNaN(advice.z)){
				point.z = advice.z;
				pointChange = true;
			}
			if(pointChange){
				var oldPos: Point3D = item.position3D;
				item.position3D = point;
				if (oldPos)
				{
					oldPos.release();
				}
			}
			if (!isNaN(advice.rotation)){
				item.parallaxDisplay.display.rotation = advice.rotation;
			}
		}
	}
}