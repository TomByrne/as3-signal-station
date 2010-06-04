package org.farmcode.sodalityLibrary.display.visualSockets
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import org.farmcode.acting.acts.AsynchronousAct;
	import org.farmcode.acting.universal.rules.AfterAct;
	import org.farmcode.acting.universal.rules.BeforeAct;
	import org.farmcode.sodality.advice.IAdvice;
	import org.farmcode.sodalityLibrary.display.visualSockets.events.SocketContainerEvent;
	import org.farmcode.sodalityLibrary.display.visualSockets.plugs.IPlugDisplay;
	import org.farmcode.sodalityLibrary.display.visualSockets.socketContainers.ISocketContainer;
	import org.farmcode.sodalityLibrary.display.visualSockets.sockets.IDisplaySocket;
	
	public class SocketBundle
	{
		// There doesn't appear to be a security checking method that doesn't involve error catching
		static protected function securityCheck(displayObject:DisplayObject):Boolean{
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
		
		private var _parent: SocketBundle;
		private var _parentContainer:ISocketContainer;
		private var _fillingSocket: IDisplaySocket;
		private var _childSockets:Dictionary;
		private var _displayObject:DisplayObject;
		private var _oldDisplayObject:DisplayObject;
		
		private var _beforeDisplayChange:AsynchronousAct;
		private var _afterDisplayChange:AsynchronousAct;
		private var _beforeRule:BeforeAct;
		private var _afterRule:AfterAct;
		
		public function SocketBundle(parent:SocketBundle, parentContainer:ISocketContainer, fillingSocket: IDisplaySocket)
		{
			_parent = parent;
			_parentContainer = parentContainer;
			_fillingSocket = fillingSocket;
			_childSockets = new Dictionary();
			
			_beforeDisplayChange = new AsynchronousAct();
			_beforeDisplayChange.addAsyncHandler(beforeDisplayChange);
			_afterDisplayChange = new AsynchronousAct();
			_afterDisplayChange.addAsyncHandler(afterDisplayChange);
		}
		public function get id(): String{
			return _fillingSocket.socketId;
		}
		public function get childSockets(): Dictionary{
			return _childSockets;
		}
		public function get path(): String{
			var path:String = "";
			var subject:SocketBundle = this;
			while(subject){
				if(subject.id && subject.id.length){
					if(path.length)path = "/"+path;
					path = subject.id+path;
				}
				subject = subject.parent;
			}
			return path;
		}
		public function get parent(): SocketBundle{
			return _parent;
		}
		public function get parentContainer(): ISocketContainer{
			return _parentContainer;
		}
		public function get fillingSocket(): IDisplaySocket{
			return _fillingSocket;
		}
		
		public function addChildContainer(parentContainer: ISocketContainer): void{
			for each(var socket:IDisplaySocket in parentContainer.childSockets){
				if(_childSockets[socket.socketId]){
					throw new Error("WebAppAdvisor: socket with id "+socket.socketId+" has already been added to container "+path);
				}else{
					_childSockets[socket.socketId] = new SocketBundle(this, parentContainer,socket);
				}
			}
		}
		public function removeChildContainer(parentContainer: ISocketContainer): void{
			for each(var socket:IDisplaySocket in parentContainer.childSockets){
				if(!_childSockets[socket.socketId]){
					throw new Error("WebAppAdvisor: no socket with id "+socket.socketId+" found in container "+path);
				}else{
					var childBundle:SocketBundle = _childSockets[socket.socketId];
					childBundle.dispose();
					delete _childSockets[socket.socketId];
				}
			}
		}
		public function dispose():void{
			_parent = null;
			_parentContainer = null;
			setPlugDisplay(null,null);
			_fillingSocket = null;
			for each(var child:SocketBundle in _childSockets){
				child.dispose();
			}
			_childSockets = null;
		}
		public function getChildSocket(socketId:String):SocketBundle{
			return _childSockets[socketId];
		}
		public function findBundle(socket:IDisplaySocket):SocketBundle{
			if(fillingSocket==socket){
				return this;
			}else{
				for each(var child:SocketBundle in _childSockets){
					var ret:SocketBundle = child.findBundle(socket);
					if(ret)return ret;
				}
			}
			return null;
		}
		public function setPlugDisplay(plugDisplay:IPlugDisplay,cause:IAdvice, dataProvider:*=null): void{
			if(_fillingSocket.plugDisplay!=plugDisplay){
				var oldPlugDisplay:IPlugDisplay = _fillingSocket.plugDisplay;
				
				if(plugDisplay){
					setDisplayObject(plugDisplay.display, false);
					_beforeRule = null;
					_afterRule = null;
					_beforeDisplayChange.addUniversalRule(_beforeRule = new BeforeAct(plugDisplay.displayChanged));
					_afterDisplayChange.addUniversalRule(_afterRule = new AfterAct(plugDisplay.displayChanged));
					findSocketContainers(plugDisplay.display,false);
				}else{
					setDisplayObject(null, false);
				}
				if(oldPlugDisplay){
					/* must clear dataProvider of old PlugDisplay before switching to
					new one so that it can clear any any child sockets*/
					oldPlugDisplay.setDataProvider(null,cause);
					_beforeDisplayChange.removeUniversalRule(_beforeRule);
					_afterDisplayChange.removeUniversalRule(_afterRule);
				}
				_fillingSocket.plugDisplay = plugDisplay;
				_fillingSocket.socketPath = path;
				completeRemoveListener();
			}
			// this must be done after adding the plugDisplay to the stage so that advice can be fired to set child slots
			if(plugDisplay){
				plugDisplay.setDataProvider(dataProvider,cause);
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
		protected function setDisplayObject(displayObject:DisplayObject, removeRemoveListener:Boolean):void{
			completeRemoveListener();
			if(_displayObject!=displayObject){
				if(_displayObject){
					_displayObject.removeEventListener(SocketContainerEvent.SOCKET_CONTAINER_ADDED, onAdded);
					_displayObject.removeEventListener(SocketContainerEvent.SOCKETS_CHANGED, onSocketsChanged);
					if(removeRemoveListener){
						_displayObject.removeEventListener(SocketContainerEvent.SOCKET_CONTAINER_REMOVED, onRemoved);
					}else{
						_oldDisplayObject = _displayObject;
					}
				}
				_displayObject = displayObject;
				if(_displayObject){
					_displayObject.addEventListener(SocketContainerEvent.SOCKET_CONTAINER_ADDED, onAdded);
					_displayObject.addEventListener(SocketContainerEvent.SOCKET_CONTAINER_REMOVED, onRemoved);
					_displayObject.addEventListener(SocketContainerEvent.SOCKETS_CHANGED, onSocketsChanged);
				}
			}
		}
		protected function completeRemoveListener():void{
			if(_oldDisplayObject){
				_oldDisplayObject.removeEventListener(SocketContainerEvent.SOCKET_CONTAINER_REMOVED, onRemoved);
				_oldDisplayObject = null;
			}
		}
		protected function onAdded(e:SocketContainerEvent): void{
			var cast:DisplayObject = (e.target as DisplayObject);
			if(cast)findSocketContainers(cast,true);
			addChildContainer(e.socketContainer);
			e.stopImmediatePropagation();
		}
		protected function onRemoved(e:SocketContainerEvent): void{
			var cast:DisplayObject = (e.target as DisplayObject);
			if(cast)findSocketContainers(cast,false);
			removeChildContainer(e.socketContainer);
			e.stopImmediatePropagation();
		}
		protected function onSocketsChanged(e:SocketContainerEvent): void{
			var cont:ISocketContainer = e.socketContainer;
			var sockets:Array = cont.childSockets;
			var socket:IDisplaySocket;
			var socketBundle:SocketBundle;
			// remove sockets that no longer exist
			for(var socketId:String in _childSockets){
				socketBundle = _childSockets[socketId];
				if(socketBundle.parentContainer==cont){
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
					_childSockets[socket.socketId] = new SocketBundle(this, cont,socket);
				}else if(socketBundle.parentContainer!=cont){
					throw new Error("WebAppAdvisor: socket with id "+socket.socketId+" has already been added to container "+path);
				}
			}
			e.stopImmediatePropagation();
		}
		protected function findSocketContainers(display:DisplayObject, add:Boolean): void{
			var parent:DisplayObjectContainer = (display as DisplayObjectContainer);
			if(parent && securityCheck(parent)){
				for(var i:int=0; i<parent.numChildren; i++){
					var child:DisplayObject = parent.getChildAt(i);
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
		}
	}
}