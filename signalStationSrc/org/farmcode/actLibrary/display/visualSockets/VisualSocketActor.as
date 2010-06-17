package org.farmcode.actLibrary.display.visualSockets
{
	import flash.events.Event;
	
	import org.farmcode.actLibrary.core.UniversalActorHelper;
	import org.farmcode.actLibrary.display.visualSockets.actTypes.IFillSocketAct;
	import org.farmcode.actLibrary.display.visualSockets.mappers.DisplayCreationResult;
	import org.farmcode.actLibrary.display.visualSockets.mappers.IPlugMapper;
	import org.farmcode.actLibrary.display.visualSockets.plugs.IPlugDisplay;
	import org.farmcode.actLibrary.display.visualSockets.sockets.IDisplaySocket;
	import org.farmcode.actLibrary.external.siteStream.SiteStreamPhases;
	import org.farmcode.actLibrary.external.siteStream.actTypes.ILookupObjectPathAct;
	import org.farmcode.acting.universal.UniversalActExecution;
	import org.farmcode.utils.MethodCallQueue;
	
	use namespace VisualSocketNamespace;

	public class VisualSocketActor extends UniversalActorHelper
	{
		private static const DEFAULT_PATH_SEP: String = "/";
		
		private var _pathSeparator: String;
		private var _rootSocketBundle: SocketBundle;
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
					_rootSocketBundle = new SocketBundle(null,null,_rootSocket);
					_pendingFillSockets.executePending();
				}else{
					_rootSocketBundle = null;
				}
			}
		}
		VisualSocketNamespace function get rootSocketBundle():SocketBundle{
			return _rootSocketBundle;
		}
		
		public var contentRequestPhases:Array = [VisualSocketPhases.FILL_SOCKET];
		[ActRule(ActClassRule)]
		[ActReaction(phases="{contentRequestPhases}")]
		public function onContentRequest(execution:UniversalActExecution, cause:IFillSocketAct):void{
			if(!_rootSocketBundle){
				_pendingFillSockets.addMethodCall([execution,cause]);
			}else if (cause.displayPath == null && cause.displaySocket){
				var bundle:SocketBundle = _rootSocketBundle.findBundle(cause.displaySocket);
				if(bundle){
					cause.displayPath = bundle.path;
					cause.displaySocket = populateNode(bundle, [], 0, cause.dataProvider, cause);
				}
				execution.continueExecution();
				
			}else if(cause.displayPath == null){
				// TODO: dispatch error act
				throw new Error("VisualSocketActor.onContentRequest: displayPath must be set.");
				execution.continueExecution();
			}else{
				var displayPath: Array = cause.displayPath.split(this.pathSeparator);
				if (displayPath.length > 0){
					if(displayPath[0] == "")displayPath.shift();
					if(displayPath[displayPath.length-1] == "")displayPath.pop();
				}
				
				cause.displaySocket = populateNode(_rootSocketBundle, displayPath, 0, cause.dataProvider, cause);
				execution.continueExecution();
			}
		}
		
		private function populateNode(socketBundle: SocketBundle, displayPath: Array, currentIndex: uint, data: *, cause:IFillSocketAct):IDisplaySocket
		{
			if (currentIndex == displayPath.length){
				var currentDisplay:IPlugDisplay = socketBundle.fillingSocket.plugDisplay;
				/*if(currentDisplay){
					currentDisplay.setDataProvider(null,cause); // clear the dp in case this instance gets reused (sometime childSockets get filled with the wrong data otherwise)
				}*/
				var displayResult:DisplayCreationResult = null;
				var currentSocket: SocketBundle = socketBundle;
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
					completeDisplayRequest(socketBundle, displayResult, cause);
				}else if(!displayResult){
					throw new Error("Cannot map data "+data+" to a display mapper at displayPath "+socketBundle.path);
				}else{
					displayResult.addEventListener(Event.COMPLETE, createCompleteHander(socketBundle,cause));
				}
				return socketBundle.fillingSocket;
			}else{
				var pathComp: String = displayPath[currentIndex];
				var targetSocket: SocketBundle = socketBundle.getChildSocket(pathComp);
				if (targetSocket == null){
					throw new Error("Cannot find displayPath: "+displayPath);
				}else{
					currentIndex++;
					populateNode(targetSocket, displayPath, currentIndex, data, cause);
					return targetSocket.fillingSocket;
				}
			}
			return null;
		}
		protected function createCompleteHander(socketBundle:SocketBundle,cause:IFillSocketAct):Function{
			var handler:Function = function(e:Event):void{
				var displayResult:DisplayCreationResult = e.target as DisplayCreationResult;
				completeDisplayRequest(socketBundle,displayResult,cause);
			}
			return handler;
		}
		protected function completeDisplayRequest(socketBundle:SocketBundle, displayResult:DisplayCreationResult, cause:IFillSocketAct):void{
			if(displayResult){
				socketBundle.setPlugDisplay(displayResult.result,cause,displayResult.data);
			}else{
				socketBundle.setPlugDisplay(null,cause);
			}
		}
	}
}