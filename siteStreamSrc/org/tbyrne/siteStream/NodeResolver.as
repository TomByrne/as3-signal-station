package org.tbyrne.siteStream
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	
	import org.tbyrne.siteStream.events.SiteStreamEvent;
	
	use namespace SiteStreamNamespace;
	
	[Event(name="parsed",type="org.farmcode.siteStream.SiteStreamEvent")]
	[Event(name="resolved",type="org.farmcode.siteStream.SiteStreamEvent")]
	[Event(name="ioError",type="flash.events.IOErrorEvent")]
	public class NodeResolver extends EventDispatcher
	{
		public function get loaded():Boolean{
			validate();
			return _loaded;
		}
		public function get path():String{
			return _path;
		}
		SiteStreamNamespace function set rootNode(value:SiteStreamNode):void{
			if(_rootNode!=value){
				_rootNode = value;
				_invalid = true;
				if(_loading)load();
			}
		}
		SiteStreamNamespace function get node():SiteStreamNode{
			return _node;
		}
		
		protected var _invalid:Boolean = true;
		protected var _loading:Boolean = false;
		protected var _loaded:Boolean = false;
		protected var _path:String;
		protected var _pathParts:Array;
		protected var _node:SiteStreamNode;
		protected var _rootNode:SiteStreamNode;
		
		public function NodeResolver(rootNode:SiteStreamNode, path:String){
			_path = path;
			this.rootNode = rootNode;
		}
		public function load():void{
			_loading = true;
			validate();
			if(!_invalid)checkPath(true);
		}
		protected function validate():void{
			if(_invalid && _rootNode){
				_invalid = false;
				if(_path){
					_pathParts = _path.split(/[\/\\]/);
					// strip empty parts
					var i:int=0;
					while(i<_pathParts.length){
						var part:String = _pathParts[i];
						if(!part || !_pathParts.length){
							_pathParts.splice(i,1);
						}else{
							i++;
						}
					}
				}else{
					_pathParts = [];
				}
				_node = _rootNode;
				checkPath(false);
			}
		}
		protected function checkPath(doResolve:Boolean):void{
			if(!isNodeReady(_node)){
				if(doResolve){
					waitForNode(_node);
				}
			}else{
				if(_pathParts.length){
					var id:String = _pathParts.shift();
					var child:SiteStreamNode = _node.getChildNode(id);
					if(!child){
						throw new Error("Couldn't find item: "+ id+" within node "+_node.id+" (resolving "+this.path+")");
					}
					_node = child;
					checkPath(doResolve);
				}else{
					_loaded = true;
					if(doResolve){
						dispatchResolved();
					}
				}
			}
		}
		protected function isNodeReady(_node:SiteStreamNode):Boolean{
			return _node.dataLoaded && _node.allResolved;
		}
		protected function waitForNode(_node:SiteStreamNode):void{
			_node.addEventListener(SiteStreamEvent.RESOLVED, onNodeReady);
			if(!_node.dataLoaded)_node.beginResolve();
		}
		protected function stopWaitingForNode(_node:SiteStreamNode):void{
			_node.removeEventListener(SiteStreamEvent.RESOLVED, onNodeReady);
		}
		protected function dispatchResolved():void{
			dispatchEvent(new SiteStreamEvent(SiteStreamEvent.RESOLVED,_node.propertyInfo.value));
		}
		protected function onNodeReady(e:Event):void{
			if(_node.dataLoaded){ // otherwise it's still a stub
				if(_node==_rootNode){
					// remove first part if it matches the root page id
					if(_pathParts.length && _rootNode.idEquals(_pathParts[0])){
						_pathParts.shift();
					}
				}
				stopWaitingForNode(_node);
				checkPath(true);
			}
		}
	}
}