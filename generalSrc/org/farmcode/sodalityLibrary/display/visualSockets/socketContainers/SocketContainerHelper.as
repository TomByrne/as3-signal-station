package org.farmcode.sodalityLibrary.display.visualSockets.socketContainers
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.sodality.advice.IAdvice;
	import org.farmcode.sodality.advisors.IAdvisor;
	import org.farmcode.sodalityLibrary.display.visualSockets.advice.FillSocketAdvice;
	import org.farmcode.sodalityLibrary.display.visualSockets.advice.LookupFillSocketAdvice;
	import org.farmcode.sodalityLibrary.display.visualSockets.events.SocketContainerEvent;
	import org.farmcode.sodalityLibrary.display.visualSockets.sockets.DisplaySocket;
	import org.farmcode.sodalityLibrary.display.visualSockets.sockets.IDisplaySocket;

	public class SocketContainerHelper
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
		protected var _advisor:IAdvisor;
		protected var _display:DisplayObject;
		private var _childSockets: Array = [];
		private var _socketContainer:ISocketContainer;
		private var _dataPropertyBindings:Dictionary;
		private var _childDataFilter:Dictionary;
		private var _added:Boolean;
		private var _defaultContainer:DisplayObjectContainer;
		
		public function SocketContainerHelper(socketContainer:ISocketContainer, advisor:IAdvisor){
			_socketContainer = socketContainer;
			_advisor = advisor;
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
				if(changed)dispatchSocketChange();
			}
		}
		public function get defaultContainer(): DisplayObjectContainer{
			return this._defaultContainer;
		}
		public function set defaultContainer(value: DisplayObjectContainer):void{
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
		public function set display(value:DisplayObject):void{
			if(_display!=value){
				if(_display){
					_display.removeEventListener(Event.ADDED_TO_STAGE, onAdded);
					_display.removeEventListener(Event.REMOVED_FROM_STAGE, onRemoved);
					if(_display.stage)onRemoved();
				}
				_display = value;
				if(value){
					value.addEventListener(Event.ADDED_TO_STAGE, onAdded);
					value.addEventListener(Event.REMOVED_FROM_STAGE, onRemoved);
					if(value.stage)onAdded();
				}
			}
		}
		public function get display():DisplayObject{
			return _display;
		}
		public function setDataProvider(value:*, cause:IAdvice=null):void{
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
				checkDataProvider(cause);
			}
		}
		protected function onAdded(e:Event=null): void{
			if(!_added){
				_added = true;
				_display.dispatchEvent(new SocketContainerEvent(SocketContainerEvent.SOCKET_CONTAINER_ADDED,_socketContainer,true));
				if(_dataProvider!=null)checkDataProvider();
			}
		}
		protected function onRemoved(e:Event=null): void{
			if(_added){
				_added = false;
				_display.dispatchEvent(new SocketContainerEvent(SocketContainerEvent.SOCKET_CONTAINER_REMOVED,_socketContainer,true));
			}
		}
		protected function onDataChange(e:Event): void{
			checkChildData();
		}
		protected function checkDataProvider(cause:IAdvice=null): void{
			if(_display && _display.stage && (_dataProvider!=_lastDataProvider)){
				_lastDataProvider = _dataProvider;
				checkChildData(cause);
			}
		}
		protected function checkChildData(cause:IAdvice=null): void{
			if(_display && _display.stage){
				if(_childDataAssessed)_childDataAssessed.perform(this);
				for(var socketId:String in _dataPropertyBindings){
					var index:int = getSocketIndex(socketId, _childSockets);
					var socket:IDisplaySocket = _childSockets[index];
					if(socket){
						var prop:String = _dataPropertyBindings[socketId];
						var childData:*;
						var parts:Array = prop.split(",");
						for each(prop in parts){
							childData = SocketContainerUtils.getProperty(_dataProvider,prop);
							if(childData)break;
						}
						var filter:* = _childDataFilter[socket];
						if(filter!=childData || (!socket.plugDisplay && childData!=null)){
							if(childData){
								_childDataFilter[socket] = childData;
							}else{
								delete _childDataFilter[socket];
							}
							var fillSocket:FillSocketAdvice;
							if(typeof(childData)=="string"){
								fillSocket = new LookupFillSocketAdvice(null,childData);
							}else{
								fillSocket = new FillSocketAdvice(null, childData)
							}
							fillSocket.displaySocket = socket;
							if(cause){
								fillSocket.executeAfter = cause;
							}
							_advisor.dispatchEvent(fillSocket);
						}
					}
				}
			}
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
				if(dispatchEvent)dispatchSocketChange();
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
				if(dispatchEvent)dispatchSocketChange();
			}
		}
		protected function getSocketIndex(socketId:String, within:Array): int{
			for(var i:int=0; i<within.length; i++){
				var socket:IDisplaySocket = within[i];
				if(socket.socketId==socketId)return i;
			}
			return -1;
		}
		protected function dispatchSocketChange():void{
			if(_display && _display.stage)_display.dispatchEvent(new SocketContainerEvent(SocketContainerEvent.SOCKETS_CHANGED,_socketContainer,true));
		}
	}
}