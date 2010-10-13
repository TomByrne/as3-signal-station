package org.tbyrne.actLibrary.display.visualSockets.socketContainers
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	
	import org.tbyrne.actLibrary.core.UniversalActorHelper;
	import org.tbyrne.actLibrary.display.visualSockets.SocketManager;
	import org.tbyrne.actLibrary.display.visualSockets.acts.FillSocketAct;
	import org.tbyrne.actLibrary.display.visualSockets.acts.LookupFillSocketAct;
	import org.tbyrne.actLibrary.display.visualSockets.events.SocketContainerEvent;
	import org.tbyrne.actLibrary.display.visualSockets.sockets.DisplaySocket;
	import org.tbyrne.actLibrary.display.visualSockets.sockets.IDisplaySocket;
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.acting.universal.UniversalActExecution;
	import org.tbyrne.display.assets.assetTypes.IContainerAsset;
	import org.tbyrne.utils.ObjectUtils;

	public class SocketContainerHelper extends UniversalActorHelper
	{
		
		/**
		 * handler(from:SocketContainerHelper)
		 */
		public function get childDataAssessed():IAct{
			if(!_childDataAssessed)_childDataAssessed = new Act();
			return _childDataAssessed;
		}
		
		protected var _childDataAssessed:Act;
		protected var _dataProvider:*;
		protected var _lastDataProvider:*;
		protected var _dataProviderDispatcher:IEventDispatcher;
		//protected var _display:DisplayObject;
		private var _childSockets: Array = [];
		private var _dataPropertyBindings:Dictionary;
		private var _childDataFilter:Dictionary;
		//private var _added:Boolean;
		private var _defaultContainer:IContainerAsset;
		private var _lookupFillActs:Array = [];
		private var _fillActs:Array = [];
		
		protected var _socketContainer:ISocketContainer;
		protected var _socketsChanged:Act;
		
		public function SocketContainerHelper(socketContainer:ISocketContainer, socketsChanged:Act){
			_socketContainer = socketContainer;
			_socketsChanged = socketsChanged;
		}
		
		public function get childSockets(): Array{
			return this._childSockets;
		}
		public function set childSockets(value: Array):void{
			if(_childSockets!=value){
				var socket:IDisplaySocket;
				var i:int=0;
				var changed:Boolean;
				while( i<_childSockets.length){
					socket = _childSockets[i];
					if(!value || value.indexOf(socket)==-1){
						_removeSocket(socket.socketId,false,false);
					}else{
						i++;
					}
				}
				for each(socket in value){
					if(_childSockets.indexOf(socket)==-1){
						changed = true;
						_addSocket(socket,null,false);
					}
				}
				if(changed)_socketsChanged.perform(_socketContainer);
			}
		}
		public function get defaultContainer(): IContainerAsset{
			return this._defaultContainer;
		}
		public function set defaultContainer(value: IContainerAsset):void{
			if(_defaultContainer!=value){
				for each(var socket:IDisplaySocket in _childSockets){
					var cast:DisplaySocket = (socket as DisplaySocket);
					if(cast && cast.container==_defaultContainer){
						cast.container = value;
					}
				}
				_defaultContainer = value;
			}
		}
		public function get dataPropertyBindings(): Dictionary{
			return this._dataPropertyBindings;
		}
		public function set dataPropertyBindings(value: Dictionary):void{
			if(_dataPropertyBindings!=value){
				_dataPropertyBindings = value;
				checkDataProvider();
			}
		}
		/*public function set display(value:DisplayObject):void{
			if(_display!=value){
				if(_display){
					_display.addedToStage.removeHandler(onAdded);
					_display.removedFromStage.removeHandler(onRemoved);
					if(_display.stage)onRemoved();
				}
				_display = value;
				if(_display){
					_display.addedToStage.addHandler(onAdded);
					_display.removedFromStage.addHandler(onRemoved);
					if(_display.stage)onAdded();
				}
			}
		}
		public function get display():IDisplayAsset{
			return _display;
		}*/
		public function setDataProvider(value:*, execution:UniversalActExecution=null):void{
			if(_dataProvider!=value){
				if(_dataProviderDispatcher){
					_dataProviderDispatcher.removeEventListener(Event.CHANGE, onDataChange);
				}
				_dataProvider = value;
				_dataProviderDispatcher = (value as IEventDispatcher);
				if(_dataProviderDispatcher){
					_dataProviderDispatcher.addEventListener(Event.CHANGE, onDataChange);
				}
				if(!_childDataFilter){
					_childDataFilter = new Dictionary(true);
				}
				checkDataProvider(execution);
			}
		}
		/*protected function onAdded(e:Event=null): void{
			if(!_added){
				_added = true;
				_display.drawDisplay.dispatchEvent(new SocketContainerEvent(SocketContainerEvent.SOCKET_CONTAINER_ADDED,_socketContainer,true));
				if(_dataProvider!=null)checkDataProvider();
			}
		}
		protected function onRemoved(e:Event=null): void{
			if(_added){
				_added = false;
				_display.drawDisplay.dispatchEvent(new SocketContainerEvent(SocketContainerEvent.SOCKET_CONTAINER_REMOVED,_socketContainer,true));
			}
		}*/
		
		// TODO: use some registration system instead of event dispatching
		override protected function setAdded(value:Boolean):void{
			super.setAdded(value);
			if(value){
				SocketManager.addSocketContainer(_socketContainer);
				//_scopeDisplay.dispatchEvent(new SocketContainerEvent(SocketContainerEvent.SOCKET_CONTAINER_ADDED,_socketContainer,true));
				if(_dataProvider!=null)checkDataProvider();
			}else{
				SocketManager.removeSocketContainer(_socketContainer);
				//_scopeDisplay.dispatchEvent(new SocketContainerEvent(SocketContainerEvent.SOCKET_CONTAINER_REMOVED,_socketContainer,true));
			}
		}
		protected function onDataChange(e:Event): void{
			checkChildData();
		}
		protected function checkDataProvider(execution:UniversalActExecution=null): void{
			if(_added && (_dataProvider!=_lastDataProvider)){
				_lastDataProvider = _dataProvider;
				checkChildData(execution);
			}
		}
		protected function checkChildData(execution:UniversalActExecution=null): void{
			if(_added){
				if(_childDataAssessed)_childDataAssessed.perform(this);
				var fillIndex:int = 0;
				var lookupIndex:int = 0;
				for(var socketId:String in _dataPropertyBindings){
					var index:int = getSocketIndex(socketId, _childSockets);
					var socket:IDisplaySocket = _childSockets[index];
					if(socket){
						var prop:String = _dataPropertyBindings[socketId];
						var childData:*;
						var parts:Array = prop.split(",");
						for each(prop in parts){
							childData = ObjectUtils.getProperty(_dataProvider,prop);
							if(childData)break;
						}
						var filter:* = _childDataFilter[socket];
						if(filter!=childData || (!socket.plugDisplay && childData!=null)){
							if(childData){
								_childDataFilter[socket] = childData;
							}else{
								delete _childDataFilter[socket];
							}
							var fillSocket:FillSocketAct;
							if(typeof(childData)=="string"){
								lookupIndex++;
								fillSocket = getLookupAct(_lookupFillActs, lookupIndex,childData);
							}else{
								fillIndex++;
								fillSocket = getFillAct(_fillActs, fillIndex, childData)
							}
							fillSocket.displaySocket = socket;
							fillSocket.perform(execution);
						}
					}
				}
			}
		}
		public function getLookupAct(from:Array, index:int, dataPath:String): LookupFillSocketAct{
			var lookupAct:LookupFillSocketAct = from[index];
			if(!lookupAct){
				lookupAct = new LookupFillSocketAct(null,dataPath);
				from[index] = lookupAct;
				addChild(lookupAct);
			}else{
				lookupAct.dataPath = dataPath;
			}
			return lookupAct;
		}
		public function getFillAct(from:Array, index:int, childData:*): FillSocketAct{
			var fillSocket:FillSocketAct = new FillSocketAct(null, childData)
			fillSocket = from[index];
			if(!fillSocket){
				fillSocket = new FillSocketAct(null,childData);
				from[index] = fillSocket;
				addChild(fillSocket);
			}else{
				fillSocket.dataProvider = childData;
			}
			return fillSocket;
		}
		public function addSocket(socket:IDisplaySocket, dataProperty:String=null): void{
			_addSocket(socket, dataProperty, true);
		}
		public function _addSocket(socket:IDisplaySocket, dataProperty:String=null, dispatchEvent:Boolean=true): void{
			if(getSocketIndex(socket.socketId, _childSockets)!=-1){
				throw new Error("This socket already exists in this socket container.");
			}else{
				_childSockets.push(socket);
				if(dataProperty)bindSocketToDataProperty(socket.socketId, dataProperty);
				var cast:DisplaySocket = (socket as DisplaySocket);
				if(!cast.container)cast.container = defaultContainer;
				if(dispatchEvent)_socketsChanged.perform(_socketContainer);
			}
		}
		public function bindSocketToDataProperty(socketId:String, dataProperty:String): void{
			if(!_dataPropertyBindings)_dataPropertyBindings = new Dictionary();
			_dataPropertyBindings[socketId] = dataProperty;
		}
		public function unbindSocket(socketId:String): void{
			delete _dataPropertyBindings[socketId];
		}
		public function removeSocket(socketId:String, unbindSocket:Boolean=true): void{
			_removeSocket(socketId, unbindSocket, true);
		}
		protected function _removeSocket(socketId:String, unbindSocket:Boolean=true, dispatchEvent:Boolean=true): void{
			var index:int = getSocketIndex(socketId, _childSockets);
			if(index==-1){
				throw new Error("This socket doesn't exist in this socket container.");
			}else{
				if(unbindSocket)this.unbindSocket(socketId);
				var socket:IDisplaySocket = _childSockets.splice(index,1)[0];
				if(socket.plugDisplay)socket.plugDisplay.setDataProvider(null,null);
				var cast:DisplaySocket = (socket as DisplaySocket);
				if(cast.container==defaultContainer)cast.container = null;
				if(dispatchEvent)_socketsChanged.perform(_socketContainer);
			}
		}
		protected function getSocketIndex(socketId:String, within:Array): int{
			for(var i:int=0; i<within.length; i++){
				var socket:IDisplaySocket = within[i];
				if(socket.socketId==socketId)return i;
			}
			return -1;
		}
	}
}