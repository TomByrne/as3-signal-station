package org.tbyrne.application
{
	import flash.geom.Point;
	
	import flashx.textLayout.debug.assert;
	
	import org.farmcode.binding.PropertyWatcher;
	import org.farmcode.core.IApplication;
	import org.farmcode.data.core.StringData;
	import org.farmcode.data.dataTypes.INumberProvider;
	import org.farmcode.debug.DebugManager;
	import org.farmcode.debug.data.baseMetrics.GarbageCollect;
	import org.farmcode.debug.data.baseMetrics.IntendedFrameRate;
	import org.farmcode.debug.data.baseMetrics.MemoryUsage;
	import org.farmcode.debug.data.baseMetrics.RealFrameRate;
	import org.farmcode.debug.data.core.DebugData;
	import org.farmcode.debug.nodes.DebugDataNode;
	import org.farmcode.debug.nodes.GraphStatisticNode;
	import org.farmcode.display.assets.assetTypes.IContainerAsset;
	import org.farmcode.display.assets.assetTypes.IDisplayAsset;
	import org.farmcode.display.core.ScopedObject;
	import org.farmcode.math.units.MemoryUnitConverter;
	import org.puremvc.as3.patterns.facade.Facade;
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
			}
		}
		
		protected var _container:IContainerAsset;
		protected var _appPosition:Point;
		protected var _appSize:Point;
		protected var _facade:Facade;
		protected var _hasStarted:Boolean;
		
		CONFIG::debug{
			protected var _scopedObject:ScopedObject;
		}
		
		
		public function PureMvcApplication(){
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
				_facade.sendNotification(ApplicationNotifications.START_UP);
				
				
				CONFIG::debug{
					_scopedObject = new ScopedObject(_container);
					
					var memory:INumberProvider = new MemoryUnitConverter(new MemoryUsage(),MemoryUnitConverter.BYTES,MemoryUnitConverter.MEGABYTES)
					DebugManager.addDebugNode(new GraphStatisticNode(_scopedObject,"Mem",0x009900,memory,true));
					
					var fps:GraphStatisticNode = new GraphStatisticNode(_scopedObject,"FPS",0x990000,new RealFrameRate(),true);
					fps.maximumProvider = new IntendedFrameRate(_scopedObject);
					DebugManager.addDebugNode(fps);
					DebugManager.addDebugNode(new DebugDataNode(_scopedObject,new DebugData(new StringData("Garbage Collect"),new GarbageCollect())));
				}
			}
			addToContainer();
			_container.removedFromStage.addTempHandler(onRemovedFromStage);
			if(_appPosition)setApplicationPos();
			if(_appSize)setApplicationSize();
		}
		private function onRemovedFromStage(from:IDisplayAsset=null):void{
			removeFromContainer();
			_container.addedToStage.addTempHandler(onAddedToStage);
		}
	}
}