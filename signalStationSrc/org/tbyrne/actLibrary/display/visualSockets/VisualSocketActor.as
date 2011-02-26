package org.tbyrne.actLibrary.display.visualSockets
{
	import flash.events.Event;
	
	import org.tbyrne.actLibrary.core.UniversalActorHelper;
	import org.tbyrne.actLibrary.display.visualSockets.actTypes.IFillSocketAct;
	import org.tbyrne.actLibrary.display.visualSockets.mappers.DisplayCreationResult;
	import org.tbyrne.actLibrary.display.visualSockets.mappers.IPlugMapper;
	import org.tbyrne.actLibrary.display.visualSockets.plugs.IPlugDisplay;
	import org.tbyrne.actLibrary.display.visualSockets.sockets.IDisplaySocket;
	import org.tbyrne.acting.universal.UniversalActExecution;
	import org.tbyrne.utils.MethodCallQueue;
	
	use namespace VisualSocketNamespace;

	public class VisualSocketActor extends UniversalActorHelper
	{
		private static const DEFAULT_PATH_SEP: String = "/";
		
		private var _pathSeparator: String;
		private var _rootSocketBundle: SocketManager;
		private var _rootSocket:IDisplaySocket;
		private var _rootDataMappers: Array;
		private var _pendingFillSockets:MethodCallQueue;

		public function VisualSocketActor(rootSocket:IDisplaySocket = null){
			super();
			_pendingFillSockets = new MethodCallQueue(onContentRequest);
			
			this.pathSeparator = VisualSocketActor.DEFAULT_PATH_SEP;
			
			this._rootDataMappers = new Array();
			this.rootSocket = rootSocket;
			this.metadataTarget = this;
		}
		
		public function get rootDataMappers(): Array
		{
			return this._rootDataMappers;
		}
		public function set rootDataMappers(value: Array): void{
			this._rootDataMappers = value;
		}
		public function get pathSeparator(): String{
			return this._pathSeparator;
		}
		public function set pathSeparator(value: String): void{
			this._pathSeparator = value;
		}
		public function get rootSocket():IDisplaySocket{
			return this._rootSocket;
		}
		public function set rootSocket(value:IDisplaySocket): void{
			if (value != _rootSocket){
				this._rootSocket = value;
				if(value){
					_rootSocketBundle = new SocketManager(null,null,_rootSocket);
					_pendingFillSockets.executePending();
				}else{
					_rootSocketBundle = null;
				}
			}
		}
		VisualSocketNamespace function get rootSocketBundle():SocketManager{
			return _rootSocketBundle;
		}
		
		public var contentRequestPhases:Array = [VisualSocketPhases.FILL_SOCKET];
		[ActRule(ActClassRule)]
		[ActReaction(phases="<contentRequestPhases>")]
		public function onContentRequest(execution:UniversalActExecution, cause:IFillSocketAct):void{
			if(!_rootSocketBundle){
				_pendingFillSockets.addMethodCall([execution,cause]);
			}else if (cause.displayPath == null && cause.displaySocket){
				var bundle:SocketManager = _rootSocketBundle.findBundle(cause.displaySocket);
				if(bundle){
					cause.displayPath = bundle.path;
					cause.displaySocket = populateNode(bundle, [], 0, cause.dataProvider, execution);
				}
				execution.continueExecution();
				
			}else if(cause.displayPath == null){
				// TODO: dispatch error act
				Log.error( "VisualSocketActor.onContentRequest: displayPath must be set");
				execution.continueExecution();
			}else{
				var displayPath: Array = cause.displayPath.split(this.pathSeparator);
				if (displayPath.length > 0){
					if(displayPath[0] == "")displayPath.shift();
					if(displayPath[displayPath.length-1] == "")displayPath.pop();
				}
				
				cause.displaySocket = populateNode(_rootSocketBundle, displayPath, 0, cause.dataProvider, execution);
				execution.continueExecution();
			}
		}
		
		private function populateNode(socketBundle: SocketManager, displayPath: Array, currentIndex: uint, data: *, execution:UniversalActExecution):IDisplaySocket
		{
			if (currentIndex == displayPath.length){
				var currentDisplay:IPlugDisplay = socketBundle.fillingSocket.plugDisplay;
				/*if(currentDisplay){
					currentDisplay.setDataProvider(null,cause); // clear the dp in case this instance gets reused (sometime childSockets get filled with the wrong data otherwise)
				}*/
				var displayResult:DisplayCreationResult = null;
				var currentSocket: SocketManager = socketBundle;
				while (displayResult == null){
					var testMappers: Array = null;
					if (!currentSocket || !currentSocket.fillingSocket){
						testMappers = this.rootDataMappers;
					}else{
						testMappers = currentSocket.fillingSocket.plugMappers;
					}
					if(testMappers){
						for (var i: uint = 0; displayResult == null && i < testMappers.length; i++){
							var testMapper: IPlugMapper = testMappers[i];
							displayResult = testMapper.createPlug(data, currentDisplay);
						}
					}
					if(!currentSocket)break;
					currentSocket = currentSocket.parent;
					currentIndex--;
				}
				
				if(!data || (displayResult && displayResult.complete)){
					completeDisplayRequest(socketBundle, displayResult, execution);
				}else if(!displayResult){
					Log.error( "VisualSocketActor.populateNode: Cannot map data "+data+" to a display mapper at displayPath "+socketBundle.path);
				}else{
					displayResult.addEventListener(Event.COMPLETE, createCompleteHander(socketBundle,execution));
				}
				return socketBundle.fillingSocket;
			}else{
				var pathComp: String = displayPath[currentIndex];
				var targetSocket: SocketManager = socketBundle.getChildSocket(pathComp);
				if (targetSocket == null){
					Log.error( "VisualSocketActor.populateNode: Cannot find displayPath: "+displayPath);
				}else{
					currentIndex++;
					populateNode(targetSocket, displayPath, currentIndex, data, execution);
					return targetSocket.fillingSocket;
				}
			}
			return null;
		}
		protected function createCompleteHander(socketBundle:SocketManager,execution:UniversalActExecution):Function{
			var handler:Function = function(e:Event):void{
				var displayResult:DisplayCreationResult = e.target as DisplayCreationResult;
				completeDisplayRequest(socketBundle,displayResult,execution);
			}
			return handler;
		}
		protected function completeDisplayRequest(socketBundle:SocketManager, displayResult:DisplayCreationResult, execution:UniversalActExecution):void{
			if(displayResult){
				socketBundle.setPlugDisplay(displayResult.result,execution,displayResult.data);
			}else{
				socketBundle.setPlugDisplay(null,execution);
			}
		}
	}
}