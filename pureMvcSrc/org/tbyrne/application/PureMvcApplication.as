package org.tbyrne.application
{
	import flash.geom.Point;
	
	import org.puremvc.as3.patterns.facade.Facade;
	import org.tbyrne.core.IApplication;
	import org.tbyrne.data.core.StringData;
	import org.tbyrne.data.dataTypes.INumberProvider;
	import org.tbyrne.debug.DebugManager;
	import org.tbyrne.debug.data.baseMetrics.GarbageCollect;
	import org.tbyrne.debug.data.baseMetrics.IntendedFrameRate;
	import org.tbyrne.debug.data.baseMetrics.MemoryUsage;
	import org.tbyrne.debug.data.baseMetrics.RealFrameRate;
	import org.tbyrne.debug.data.core.DebugData;
	import org.tbyrne.debug.nodes.DebugDataNode;
	import org.tbyrne.debug.nodes.GraphStatisticNode;
	import org.tbyrne.display.assets.assetTypes.IContainerAsset;
	import org.tbyrne.display.assets.assetTypes.IDisplayAsset;
	import org.tbyrne.display.core.ScopedObject;
	import org.tbyrne.math.units.MemoryUnitConverter;
	import org.tbyrne.notifications.ApplicationNotifications;
	
	public class PureMvcApplication implements IApplication
	{
		
		public function get container():IContainerAsset{
			return _container;
		}
		public function set container(value:IContainerAsset):void{
			if(_container!=value){
				if(_container){
					if(_container.stage){
						removeFromContainer();
						_container.removedFromStage.removeHandler(onRemovedFromStage);
					}else{
						_container.addedToStage.removeHandler(onAddedToStage);
					}
				}
				_container = value;
				CONFIG::debug{
					if(_scopedObject)_scopedObject.asset = value;
				}
				if(_container){
					if(!_facade){
						_facade = createFacade();
					}
					if(_container.stage)onAddedToStage();
					else _container.addedToStage.addTempHandler(onAddedToStage);
				}
				_scopedObject.asset = _container;
			}
		}
		
		protected var _container:IContainerAsset;
		protected var _appPosition:Point;
		protected var _appSize:Point;
		protected var _facade:Facade;
		protected var _hasStarted:Boolean;
		protected var _scopedObject:ScopedObject;
		
		
		public function PureMvcApplication(){
			_scopedObject = new ScopedObject();
		}
		public function setPosition(x:Number, y:Number):void{
			if(!_appPosition){
				_appPosition = new Point();
			}
			var change:Boolean = false;
			if(_appPosition.x!=x){
				_appPosition.x = x;
				change = true;
			}
			if(_appPosition.y!=y){
				_appPosition.y = y;
				change = true;
			}
			if(change && _container){
				setApplicationPos();
			}
		}	
		public function setSize(width:Number, height:Number):void{
			if(!_appSize){
				_appSize = new Point();
			}
			var change:Boolean = false;
			if(_appSize.x!=width){
				_appSize.x = width;
				change = true;
			}
			if(_appSize.y!=height){
				_appSize.y = height;
				change = true;
			}
			if(change && _container){
				setApplicationSize();
			}
		}
		
		
		
		protected function createFacade():Facade{
			// create Facade and add initial Mediators/Proxies/Commands
			return null;
		}
		protected function addToContainer():void{
			//add initial UI Mediator to container
		}
		protected function removeFromContainer():void{
			//remove initial UI Mediator to container
		}
		protected function setApplicationPos():void{
			if(_hasStarted)_facade.sendNotification(ApplicationNotifications.SET_APP_POS,_appPosition);
		}
		protected function setApplicationSize():void{
			if(_hasStarted)_facade.sendNotification(ApplicationNotifications.SET_APP_SIZE,_appSize);
		}
		
		private function onAddedToStage(from:IDisplayAsset=null):void{
			if(!_hasStarted){
				_hasStarted = true;
				startApplication();
				_facade.sendNotification(ApplicationNotifications.START_UP);
			}
			addToContainer();
			_container.removedFromStage.addTempHandler(onRemovedFromStage);
			if(_appPosition)setApplicationPos();
			if(_appSize)setApplicationSize();
		}
		protected function startApplication():void{
			
			CONFIG::debug{
				
				var memory:INumberProvider = new MemoryUnitConverter(new MemoryUsage(),MemoryUnitConverter.BYTES,MemoryUnitConverter.MEGABYTES)
				DebugManager.addDebugNode(new GraphStatisticNode(_scopedObject,"Mem",0x009900,memory,true));
				
				var fps:GraphStatisticNode = new GraphStatisticNode(_scopedObject,"FPS",0x990000,new RealFrameRate(),true);
				fps.maximumProvider = new IntendedFrameRate(_scopedObject);
				DebugManager.addDebugNode(fps);
				DebugManager.addDebugNode(new DebugDataNode(_scopedObject,new DebugData(new StringData("Garbage Collect"),new GarbageCollect())));
			}
		}
		private function onRemovedFromStage(from:IDisplayAsset=null):void{
			removeFromContainer();
			_container.addedToStage.addTempHandler(onAddedToStage);
		}
	}
}