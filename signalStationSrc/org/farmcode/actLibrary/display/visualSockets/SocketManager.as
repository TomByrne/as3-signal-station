package org.farmcode.actLibrary.display.visualSockets
{
	import flash.display.Loader;
	import flash.utils.Dictionary;
	
	import org.farmcode.actLibrary.display.DisplayPhases;
	import org.farmcode.actLibrary.display.visualSockets.events.SocketContainerEvent;
	import org.farmcode.actLibrary.display.visualSockets.plugs.IPlugDisplay;
	import org.farmcode.actLibrary.display.visualSockets.socketContainers.ISocketContainer;
	import org.farmcode.actLibrary.display.visualSockets.sockets.IDisplaySocket;
	import org.farmcode.acting.universal.UniversalActExecution;
	import org.farmcode.acting.universal.reactions.MethodReaction;
	import org.farmcode.acting.universal.rules.ActInstanceRule;
	import org.farmcode.display.assets.IContainerAsset;
	import org.farmcode.display.assets.IDisplayAsset;
	
	public class SocketManager
	{
		private static var managerToDisplay:Dictionary = new Dictionary();
		private static var displayToManager:Dictionary = new Dictionary();
		private static var socketContainers:Dictionary = new Dictionary();
		
		internal static function setSocketDisplay(socketManager:SocketManager, display:IDisplayAsset):void{
			var oldDisplay:IDisplayAsset = managerToDisplay[socketManager];
			if(oldDisplay != display){
				var i:*;
				var socketCont:ISocketContainer;
				var manager:SocketManager;
				
				delete displayToManager[oldDisplay];
				
				var parent:SocketManager = findManagerFor(display);
				
				if(display){
					managerToDisplay[socketManager] = display;
					displayToManager[display] = socketManager
				}else{
					delete managerToDisplay[socketManager];
				}
				
				// move/remove old socketContainers
				for(i in socketManager.socketContainers){
					socketCont = (i as ISocketContainer);
					manager = findManagerFor(socketCont.asset);
					if(manager!=socketManager){
						socketManager.removeChildContainer(socketCont);
						if(manager){
							manager.addChildContainer(socketCont);
						}
						socketContainers[socketCont] = manager;
					}
				}
				// add new ones
				var hasParent:Boolean = (parent!=null);
				var searchDict:Dictionary = (hasParent?parent.socketContainers:socketContainers);
				for(i in searchDict){
					socketCont = (i as ISocketContainer);
					manager = findManagerFor(socketCont.asset);
					if(manager==socketManager){
						socketContainers[socketCont] = socketManager;
						socketManager.addChildContainer(socketCont);
						if(hasParent){
							parent.removeChildContainer(socketCont);
						}
					}
				}
			}
		}
		public static function addSocketContainer(socketContainer:ISocketContainer):void{
			if(!socketContainers[socketContainer]){
				var manager:SocketManager = findManagerFor(socketContainer.asset);
				if(manager)manager.addChildContainer(socketContainer);
				socketContainer.assetChanged.addHandler(onSocketContDisplayChanged);
				socketContainers[socketContainer] = manager;
			}else{
				throw new Error("socketContainer already added");
			}
		}
		public static function removeSocketContainer(socketContainer:ISocketContainer):void{
			var manager:SocketManager = socketContainers[socketContainer];
			if(manager){
				manager.removeChildContainer(socketContainer);
				socketContainer.assetChanged.removeHandler(onSocketContDisplayChanged);
			}
			delete socketContainers[socketContainer];
		}
		private static function onSocketContDisplayChanged(socketContainer:ISocketContainer):void{
			var oldManager:SocketManager = socketContainers[socketContainer];
			var newManager:SocketManager = findManagerFor(socketContainer.asset);
			if(oldManager!=newManager){
				if(oldManager)oldManager.removeChildContainer(socketContainer);
				if(newManager)newManager.addChildContainer(socketContainer);
				socketContainers[socketContainer] = newManager;
			}
		}
		private static function findManagerFor(scopeDisplay:IDisplayAsset):SocketManager{
			var manager:SocketManager;
			if(scopeDisplay){
				var subject:IDisplayAsset = scopeDisplay;
				while(subject){
					manager = displayToManager[subject];
					if(manager)return manager;
					subject = subject.parent;
				}
			}
			return null;
		}
		
		
		// There doesn't appear to be a security checking method that doesn't involve error catching
		static protected function securityCheck(displayObject:IDisplayAsset):Boolean{
			var loader:Loader = (displayObject as Loader);
			if(loader && loader.contentLoaderInfo.url){
				try{
					loader.content;
					return true;
				}catch(e:Error){
					return false;
				}
			}
			return true;
		}
		
		internal function get socketContainers():Dictionary{
			return _socketContainers;
		}
		
		private var _parent: SocketManager;
		private var _parentContainer:ISocketContainer;
		private var _fillingSocket: IDisplaySocket;
		private var _childSockets:Dictionary;
		private var _displayObject:IDisplayAsset;
		private var _oldDisplayObject:IDisplayAsset;
		private var _socketContainers:Dictionary = new Dictionary();
		
		//private var _beforeDisplayChange:AsynchronousAct;
		//private var _afterDisplayChange:AsynchronousAct;
		/*private var _beforeRule:BeforeAct;
		private var _afterRule:AfterAct;*/
		
		private var _beforeRule:ActInstanceRule;
		private var _afterRule:ActInstanceRule;
		private var _beforeDisplayChange:MethodReaction;
		private var _afterDisplayChange:MethodReaction;
		
		public function SocketManager(parent:SocketManager, parentContainer:ISocketContainer, fillingSocket: IDisplaySocket)
		{
			_parent = parent;
			_parentContainer = parentContainer;
			_fillingSocket = fillingSocket;
			_childSockets = new Dictionary();
			
			/*_beforeDisplayChange = new AsynchronousAct();
			_beforeDisplayChange.addAsyncHandler(beforeDisplayChange);
			_afterDisplayChange = new AsynchronousAct();
			_afterDisplayChange.addAsyncHandler(afterDisplayChange);*/
			
			_beforeRule = new ActInstanceRule(null,[DisplayPhases.DISPLAY_CHANGED]);
			_afterRule = new ActInstanceRule(null,null,[DisplayPhases.DISPLAY_CHANGED]);
			
			_beforeDisplayChange = new MethodReaction(beforeDisplayChange,true);
			_beforeDisplayChange.addUniversalRule(_beforeRule);
			_afterDisplayChange = new MethodReaction(beforeDisplayChange,true);
			_afterDisplayChange.addUniversalRule(_afterRule);
			
		}
		public function get id(): String{
			return _fillingSocket.socketId;
		}
		public function get childSockets(): Dictionary{
			return _childSockets;
		}
		public function get path(): String{
			var path:String = "";
			var subject:SocketManager = this;
			while(subject){
				if(subject.id && subject.id.length){
					if(path.length)path = "/"+path;
					path = subject.id+path;
				}
				subject = subject.parent;
			}
			return path;
		}
		public function get parent(): SocketManager{
			return _parent;
		}
		public function get parentContainer(): ISocketContainer{
			return _parentContainer;
		}
		public function get fillingSocket(): IDisplaySocket{
			return _fillingSocket;
		}
		
		public function addChildContainer(container: ISocketContainer): void{
			if(!_socketContainers[container]){
				_socketContainers[container] = true;
				container.childSocketsChanged.addHandler(onChildSocketsChanged);
				for each(var socket:IDisplaySocket in container.childSockets){
					if(_childSockets[socket.socketId]){
						throw new Error("WebAppAdvisor: socket with id "+socket.socketId+" has already been added to container "+path);
					}else{
						_childSockets[socket.socketId] = new SocketManager(this, container,socket);
					}
				}
			}
		}
		public function removeChildContainer(container: ISocketContainer): void{
			if(_socketContainers[container]){
				delete _socketContainers[container];
				container.childSocketsChanged.removeHandler(onChildSocketsChanged);
				for each(var socket:IDisplaySocket in container.childSockets){
					if(!_childSockets[socket.socketId]){
						throw new Error("WebAppAdvisor: no socket with id "+socket.socketId+" found in container "+path);
					}else{
						var childBundle:SocketManager = _childSockets[socket.socketId];
						childBundle.dispose();
						delete _childSockets[socket.socketId];
					}
				}
			}
		}
		public function dispose():void{
			_parent = null;
			_parentContainer = null;
			setPlugDisplay(null,null);
			_fillingSocket = null;
			for each(var child:SocketManager in _childSockets){
				child.dispose();
			}
			_childSockets = null;
		}
		public function getChildSocket(socketId:String):SocketManager{
			return _childSockets[socketId];
		}
		public function findBundle(socket:IDisplaySocket):SocketManager{
			if(fillingSocket==socket){
				return this;
			}else{
				for each(var child:SocketManager in _childSockets){
					var ret:SocketManager = child.findBundle(socket);
					if(ret)return ret;
				}
			}
			return null;
		}
		public function setPlugDisplay(plugDisplay:IPlugDisplay, execution:UniversalActExecution, dataProvider:*=null): void{
			if(_fillingSocket.plugDisplay!=plugDisplay){
				var oldPlugDisplay:IPlugDisplay = _fillingSocket.plugDisplay;
				
				if(plugDisplay){
					setDisplayObject(plugDisplay.display, false);
					_beforeRule.act = plugDisplay.displayChanged;
					_afterRule.act = plugDisplay.displayChanged;
					//_beforeRule = null;
					//_afterRule = null;
					//_beforeDisplayChange.addUniversalRule(_beforeRule = new ActInstanceRule(plugDisplay.displayChanged,[DisplayPhases.DISPLAY_CHANGED]));
					//_afterDisplayChange.addUniversalRule(_afterRule = new ActInstanceRule(plugDisplay.displayChanged,null,[DisplayPhases.DISPLAY_CHANGED]));
					//findSocketContainers(plugDisplay.display,false);
				}else{
					setDisplayObject(null, false);
				}
				if(oldPlugDisplay){
					/* must clear dataProvider of old PlugDisplay before switching to
					new one so that it can clear any any child sockets*/
					oldPlugDisplay.setDataProvider(null,execution);
					//_beforeDisplayChange.removeUniversalRule(_beforeRule);
					//_afterDisplayChange.removeUniversalRule(_afterRule);
					_beforeRule = null;
					_afterRule = null;
				}
				_fillingSocket.plugDisplay = plugDisplay;
				_fillingSocket.socketPath = path;
				completeRemoveListener();
			}
			// this must be done after adding the plugDisplay to the stage so that acts can be fired to set child slots
			if(plugDisplay){
				plugDisplay.setDataProvider(dataProvider,execution);
			}
		}
		protected function beforeDisplayChange(endHandler:Function):void{
			setDisplayObject(_fillingSocket.plugDisplay.display, false);
			endHandler();
		}
		protected function afterDisplayChange(endHandler:Function):void{
			completeRemoveListener();
			endHandler();
		}
		// TODO: get rid of this event shit
		protected function setDisplayObject(displayObject:IDisplayAsset, removeRemoveListener:Boolean):void{
			completeRemoveListener();
			if(_displayObject!=displayObject){
				_beforeDisplayChange.asset = displayObject;
				_afterDisplayChange.asset = displayObject;
				
				/*if(_displayObject){
					_displayObject.drawDisplay.removeEventListener(SocketContainerEvent.SOCKET_CONTAINER_ADDED, onAdded);
					_displayObject.drawDisplay.removeEventListener(SocketContainerEvent.SOCKETS_CHANGED, onSocketsChanged);
					if(removeRemoveListener){
						_displayObject.drawDisplay.removeEventListener(SocketContainerEvent.SOCKET_CONTAINER_REMOVED, onRemoved);
					}else{
						_oldDisplayObject = _displayObject;
					}
				}*/
				_displayObject = displayObject;
				SocketManager.setSocketDisplay(this,displayObject);
				/*if(_displayObject){
					_displayObject.drawDisplay.addEventListener(SocketContainerEvent.SOCKET_CONTAINER_ADDED, onAdded);
					_displayObject.drawDisplay.addEventListener(SocketContainerEvent.SOCKET_CONTAINER_REMOVED, onRemoved);
					_displayObject.drawDisplay.addEventListener(SocketContainerEvent.SOCKETS_CHANGED, onSocketsChanged);
				}*/
			}
		}
		protected function completeRemoveListener():void{
			if(_oldDisplayObject){
				//_oldDisplayObject.drawDisplay.removeEventListener(SocketContainerEvent.SOCKET_CONTAINER_REMOVED, onRemoved);
				_oldDisplayObject = null;
			}
		}
		/*protected function onAdded(e:SocketContainerEvent): void{
			var cast:IDisplayAsset = (e.target as IDisplayAsset);
			if(cast)findSocketContainers(cast,true);
			addChildContainer(e.socketContainer);
			e.stopImmediatePropagation();
		}
		protected function onRemoved(e:SocketContainerEvent): void{
			var cast:IDisplayAsset = (e.target as IDisplayAsset);
			if(cast)findSocketContainers(cast,false);
			removeChildContainer(e.socketContainer);
			e.stopImmediatePropagation();
		}*/
		protected function onChildSocketsChanged(container:ISocketContainer): void{
			var sockets:Array = container.childSockets;
			var socket:IDisplaySocket;
			var socketBundle:SocketManager;
			// remove sockets that no longer exist
			for(var socketId:String in _childSockets){
				socketBundle = _childSockets[socketId];
				if(socketBundle.parentContainer==container){
					socket = socketBundle.fillingSocket;
					if(sockets.indexOf(socket)==-1){
						socketBundle.dispose();
						delete _childSockets[socketId];
					}
				}
			}
			// add new sockets
			for each(socket in sockets){
				socketBundle = _childSockets[socket.socketId];
				if(!socketBundle){
					_childSockets[socket.socketId] = new SocketManager(this, container,socket);
				}else if(socketBundle.parentContainer!=container){
					throw new Error("WebAppAdvisor: socket with id "+socket.socketId+" has already been added to container "+path);
				}
			}
			//e.stopImmediatePropagation();
		}
		/*protected function findSocketContainers(display:IDisplayAsset, add:Boolean): void{
			var parent:IContainerAsset = (display as IContainerAsset);
			if(parent && securityCheck(parent)){
				for(var i:int=0; i<parent.numChildren; i++){
					var child:IDisplayAsset = parent.getAssetAt(i);
					if(!(child is IPlugDisplay)){
						findSocketContainers(child, add);
					}
					var sockCont:ISocketContainer = (child as ISocketContainer);
					if(sockCont){
						if(add)addChildContainer(sockCont);
						else removeChildContainer(sockCont);
					}
				}
			}
		}*/
	}
}