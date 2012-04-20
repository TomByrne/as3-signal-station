package org.tbyrne.siteStream
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	
	use namespace SiteStreamNamespace;
	
	public class NodeResolver 
	{
		
		/**
		 * handler(from:NodeResolver)
		 */
		public function get wasParsed():IAct{
			return (_wasParsed || (_wasParsed = new Act()));
		}
		
		/**
		 * handler(from:NodeResolver, resolvedValue:*)
		 */
		public function get wasResolved():IAct{
			return (_wasResolved || (_wasResolved = new Act()));
		}
		
		/**
		 * handler(from:NodeResolver)
		 */
		public function get ioErrorThrown():IAct{
			return (_ioErrorThrown || (_ioErrorThrown = new Act()));
		}
		
		protected var _ioErrorThrown:Act;
		protected var _wasResolved:Act;
		protected var _wasParsed:Act;
		
		
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
						Log.error( "NodeResolver.checkPath: Couldn't find item: "+ id+" within node "+_node.id+" (resolving "+this.path+")");
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
		protected function isNodeReady(node:SiteStreamNode):Boolean{
			return node.dataLoaded && node.allResolved;
		}
		protected function waitForNode(node:SiteStreamNode):void{
			node.wasResolved.addHandler(onNodeReady);
			if(!node.dataLoaded)node.beginResolve();
		}
		protected function stopWaitingForNode(node:SiteStreamNode):void{
			node.wasResolved.removeHandler(onNodeReady);
		}
		protected function dispatchResolved():void{
			if(_wasResolved)_wasResolved.perform(this,_node.propertyInfo.value);
		}
		protected function onNodeReady(from:SiteStreamNode):void{
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