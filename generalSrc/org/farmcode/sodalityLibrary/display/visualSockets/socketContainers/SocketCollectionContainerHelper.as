package org.farmcode.sodalityLibrary.display.visualSockets.socketContainers
{
	import flash.display.DisplayObjectContainer;
	import flash.utils.Dictionary;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.display.layout.list.ListLayoutInfo;
	import org.farmcode.sodality.advice.IAdvice;
	import org.farmcode.sodality.advisors.IAdvisor;
	import org.farmcode.sodalityLibrary.display.visualSockets.advice.FillSocketAdvice;
	import org.farmcode.sodalityLibrary.display.visualSockets.advice.LookupFillSocketAdvice;
	import org.farmcode.sodalityLibrary.display.visualSockets.sockets.DisplaySocket;
	import org.farmcode.sodalityLibrary.display.visualSockets.sockets.IDisplaySocket;
	
	public class SocketCollectionContainerHelper extends SocketContainerHelper
	{
		
		public function get collectionSocketId():String{
			return _collectionSocketId;
		}
		public function set collectionSocketId(value:String):void{
			if(_collectionSocketId!=value){
				_collectionSocketId = value;
				checkChildData();
			}
		}
		public function get collectionDataProperty():String{
			return _collectionDataProperty;
		}
		public function set collectionDataProperty(value:String):void{
			if(_collectionDataProperty!=value){
				_collectionDataProperty = value;
				checkChildData();
			}
		}
		public function get allChildSockets():Array{
			return _allChildSocket;
		}
		public function get collectionSockets():Array{
			return _collectionSockets;
		}
		public function get collectionSocketsChanged():IAct{
			return _collectionSocketsChanged;
		}
		override public function set defaultContainer(value: DisplayObjectContainer):void{
			if(super.defaultContainer!=value){
				for each(var socket:IDisplaySocket in _collectionSockets){
					var cast:DisplaySocket = (socket as DisplaySocket);
					if(cast && cast.container==super.defaultContainer){
						cast.container = value;
					}
				}
				super.defaultContainer = value;
			}
		}
		public function get collectionPlugMappers():Array{
			return _collectionPlugMappers;
		}
		public function set collectionPlugMappers(value:Array):void{
			if(_collectionPlugMappers!=value){
				_collectionPlugMappers = value;
				for each(var socket:DisplaySocket in _collectionSockets){
					socket.plugMappers = value;
				}
			}
		}
		
		
		private var _collectionSocketId:String;
		private var _collectionDataProperty:String;
		private var _collectionPlugMappers:Array;
		
		private var _allChildSocket:Array = [];
		private var _collectionSockets:Array = [];
		private var _collectionSocketsChanged:Act = new Act();
		
		public function SocketCollectionContainerHelper(socketContainer:ISocketContainer, advisor:IAdvisor){
			super(socketContainer, advisor);
		}
		override protected function checkChildData(cause:IAdvice=null): void{
			if(_display && _display.stage){
				super.checkChildData(cause);
				
				var collection:*;
				var collectionCount:int;
				var socket:DisplaySocket;
				var change:Boolean;
				var advice:Array = [];
				var fillSocket:FillSocketAdvice;
				
				var added:Array = [];
				var removed:Array = [];
				
				if(_dataProvider){
					if(_collectionDataProperty && _collectionDataProperty!="*"){
						var parts:Array = _collectionDataProperty.split(",");
						for each(var prop:String in parts){
							collection = _dataProvider[prop];
							if(collection)break;
						}
					}else{
						var array:Array = (_dataProvider as Array);
						if(array){
							collection = array;
						}else{
							var dictionary:Dictionary = (_dataProvider as Dictionary);
							if(dictionary){
								collection = dictionary;
							}else{
								collectionCount = 0;
							}
						}
					}
				}
				
				if(collection){
					var i:int=0;
					for each(var childData:* in collection){
						if(i<_collectionSockets.length){
							socket = _collectionSockets[i];
						}else{
							socket = _collectionSockets[i] = new DisplaySocket();
							socket.layoutInfo = new ListLayoutInfo(i);
							socket.plugMappers = collectionPlugMappers;
							added.push(socket);
						}
						socket.socketId = _collectionSocketId+i;
						if(typeof(childData)=="string"){
							fillSocket = new LookupFillSocketAdvice(null,childData);
						}else{
							fillSocket = new FillSocketAdvice(null, childData)
						}
						fillSocket.displaySocket = socket;
						if(cause){
							fillSocket.executeBefore = cause;
						}
						advice.push(fillSocket);
						_allChildSocket.push(socket);
						socket.container = defaultContainer;
						change = true;
						i++;
					}
					collectionCount = i;
				}
				
				for(i=collectionCount; i<_collectionSockets.length; i++){
					socket = _collectionSockets[i];
					var index:int = getSocketIndex(socket.socketId, _allChildSocket);
					if(index!=-1){
						_allChildSocket.splice(index,1);
					}
					socket.plugMappers = null;
					socket.socketId = null;
					socket.container = null;
					change = true;
					removed.push(socket);
				}
				_collectionSockets.splice(collectionCount,_collectionSockets.length-collectionCount);
				if(change){
					dispatchSocketChange();
					for each(fillSocket in advice){
						_advisor.dispatchEvent(fillSocket);
					}
				}
				_collectionSocketsChanged.perform(added,removed);
			}
		}
		override public function addSocket(socket:IDisplaySocket, dataProperty:String=null): void{
			super.addSocket(socket, dataProperty);
			if(getSocketIndex(socket.socketId, _allChildSocket)==-1){
				_allChildSocket.push(socket);
			}
		}
		override public function removeSocket(socketId:String, unbindSocket:Boolean=true): void{
			super.removeSocket(socketId, unbindSocket);
			var index:int = getSocketIndex(socketId, _allChildSocket);
			if(index!=-1){
				_allChildSocket.splice(index,1);
			}
		}
	}
}