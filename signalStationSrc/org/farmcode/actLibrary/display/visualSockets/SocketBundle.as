package org.farmcode.actLibrary.display.visualSockets
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.utils.Dictionary;
	
	import org.farmcode.actLibrary.display.DisplayPhases;
	import org.farmcode.actLibrary.display.visualSockets.actTypes.IFillSocketAct;
	import org.farmcode.actLibrary.display.visualSockets.events.SocketContainerEvent;
	import org.farmcode.actLibrary.display.visualSockets.plugs.IPlugDisplay;
	import org.farmcode.actLibrary.display.visualSockets.socketContainers.ISocketContainer;
	import org.farmcode.actLibrary.display.visualSockets.sockets.IDisplaySocket;
	import org.farmcode.acting.universal.UniversalActExecution;
	import org.farmcode.acting.universal.reactions.MethodReaction;
	import org.farmcode.acting.universal.rules.ActInstanceRule;
	
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
		
		//private var _beforeDisplayChange:AsynchronousAct;
		//private var _afterDisplayChange:AsynchronousAct;
		/*private var _beforeRule:BeforeAct;
		private var _afterRule:AfterAct;*/
		
		private var _beforeRule:ActInstanceRule;
		private var _afterRule:ActInstanceRule;
		private var _beforeDisplayChange:MethodReaction;
		private var _afterDisplayChange:MethodReaction;
		
		public function SocketBundle(parent:SocketBundle, parentContainer:ISocketContainer, fillingSocket: IDisplaySocket)
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
					findSocketContainers(plugDisplay.display,false);
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
		protected function setDisplayObject(displayObject:DisplayObject, removeRemoveListener:Boolean):void{
			completeRemoveListener();
			if(_displayObject!=displayObject){
				_beforeDisplayChange.scopeDisplay = displayObject;
				_afterDisplayChange.scopeDisplay = displayObject;
				
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