package org.tbyrne.siteStream
{
	import flash.events.Event;
	
	import org.tbyrne.collections.IIterator;
	import org.tbyrne.collections.linkedList.LinkedList;
	import org.tbyrne.core.IPendingResult;
	import org.tbyrne.hoborg.ObjectPool;
	import org.tbyrne.siteStream.events.SiteStreamEvent;
	import org.tbyrne.siteStream.parsers.ISiteStreamParser;
	import org.tbyrne.siteStream.propertyInfo.IPropertyInfo;
	
	use namespace SiteStreamNamespace;
	
	[Event(name="resolved",type="org.farmcode.siteStream.SiteStreamEvent")]
	public class SiteStreamNode extends PropertySetter
	{
		/*CONFIG::debug{
			private static var gettingNew:Boolean;
		}*/
		private static const pool:ObjectPool = new ObjectPool(SiteStreamNode);
		public static function getNew(siteStreamItem:ISiteStreamParser, propertyInfo:IPropertyInfo=null):SiteStreamNode{
			/*CONFIG::debug{
				gettingNew = true;
			}*/
			var ret:SiteStreamNode = pool.takeObject();
			/*CONFIG::debug{
				gettingNew = false;
			}*/
			ret.siteStreamItem = siteStreamItem;
			ret.propertyInfo = propertyInfo;
			return ret;
		}
		
		public function get id():String{
			return _id;
		}
		public function set id(value:String):void{
			if(_id!=value){
				if(_id && _id.length){
					Log.error("SiteStreamNode.id: SiteStreamNode id property being changed. This may be the result of non-matching XML id attribute");
				}
				_id = value;
			}
		}
		public function get dataLoaded():Boolean{
			return propertyInfo!=null && siteStreamItem.isDataLoaded(propertyInfo) && !parsedLazy;
		}
		public function get path():String{
			var path:String = id?id:"";
			var subject:SiteStreamNode = parentNode;
			while(subject && subject.parentNode){
				if(subject.id)path = subject.id+"/"+path;
				subject = subject.parentNode;
			}
			return path;
		}
		protected function get rootNode():SiteStreamNode{
			if(!_rootNode){
				_rootNode = this;
				while(_rootNode.parentNode){
					_rootNode = _rootNode.parentNode;
				}
			}
			return _rootNode;
		}
		override protected function get valueSet():Boolean{
			return super.valueSet || parsedLazy;
		}
		
		private var children:LinkedList = LinkedList.getNew();
		private var _id:String;
		private var loadingData:Boolean = false;
		private var parsedLazy:Boolean = false;
		private var isCreating:Boolean = false;
		private var _rootNode:SiteStreamNode;
		
		public function SiteStreamNode(siteStreamItem:ISiteStreamParser=null, propertyInfo:IPropertyInfo=null){
			super(siteStreamItem, propertyInfo);
			/*CONFIG::debug{
				if(!gettingNew)Log.error("SiteStreamNode should be created via SiteStreamNode.getNew");
			}*/
			//this.addEventListener(SiteStreamEvent.PARSED,checkResolved,false,0,true);
		}
		public function getChildIterator():IIterator{
			return children.getIterator();
		}
		public function idEquals(id:String):Boolean{
			var node:SiteStreamNode = (parentNode?parentNode:this);
			return node.siteStreamItem.compareChildIds(id,this.id);
		}
		public function addChild(child:SiteStreamNode):void{
			child.parentNode = this;
			children.unshift(child);
			child.addEventListener(SiteStreamEvent.RESOLVED,onChildNodeResolved,false,0,true);
			child.addEventListener(SiteStreamEvent.PARSED, onChildParsed);
		}
		
		protected function onChildNodeResolved(event:SiteStreamEvent):void{
			checkResolved(true);
		}
		public function beginResolve():void{
			beginProcess(false);
		}
		public function beginProcess(lazy:Boolean):void{
			parsedLazy = lazy;
			if(!loadingData){
				if(lazy){
					parseObject();
				}else if(propertyInfo && siteStreamItem.isDataLoaded(propertyInfo)){
					loadClass();
				}else{
					loadingData = true;
					if(!propertyInfo){
						propertyInfo = siteStreamItem.createNewPropertyInfo();
					}
					var ret:IPendingResult = siteStreamItem.loadData(propertyInfo);
					ret.success.addHandler(onDataLoadComplete);
					ret.fail.addHandler(onDataLoadFail);
				}
			}
		}
		override public function release():void{
			pool.releaseObject(this);
		}
		public function releaseObject():void{
			_releaseObject(false);
		}
		protected function get genTab():String{
			var ret:String = "";
			var subj:SiteStreamNode = this;
			while(subj.parentNode){
				subj = subj.parentNode;
				ret += "\t";
			}
			return ret;
		}
		internal function _releaseObject(parentReleased:Boolean):void{
			var release:Boolean = false;
			if(!parentReleased){
				release = siteStreamItem.releaseData(propertyInfo);
			}
			
			var iterator:IIterator = children.getIterator();
			var child:SiteStreamNode;
			while(child = iterator.next()){
				child._releaseObject(parentReleased || release);
			}
			iterator.release();
			
			if(release){
				siteStreamItem.releaseClass(propertyInfo);
				beginProcess(siteStreamItem.parseLazily(propertyInfo));
				releaseChildren();
				unloadData();
			}else if(parentReleased){
				siteStreamItem.releaseClass(propertyInfo);
			}
		}
		protected function releaseChildren():void{
			var iterator:IIterator = children.getIterator();
			var child:SiteStreamNode;
			while(child = iterator.next()){
				child.release();
			}
			iterator.release();
			children.reset();
		}
		override protected function unloadData():void{
			super.unloadData();
			if(parentNode)_siteStreamItem = parentNode.siteStreamItem;
			loadingData = false;
			parsedLazy = false;
			_allResolved = false;
			if(propertyInfo){
				propertyInfo.value = null;
				_siteStreamItem.initPropertyInfo(propertyInfo);
				_siteStreamItem.commitValue(propertyInfo,parentNode);
			}
		}
		override protected function commitValue() : void{
			if(!parsedLazy){
				super.commitValue();
			}
		}
		override public function reset():void{
			super.reset();
			parentNode = null;
			_siteStreamItem = null;
			propertyInfo = null;
			loadingData = false;
			parsedLazy = false;
			_allResolved = false;
			_id = null;
		}
		private function onDataLoadFail(pend:IPendingResult):void{
			pend.success.removeHandler(onDataLoadComplete);
			pend.fail.removeHandler(onDataLoadFail);
			loadingData = false;
		}
		private function onDataLoadComplete(pend:IPendingResult):void{
			pend.success.removeHandler(onDataLoadComplete);
			pend.fail.removeHandler(onDataLoadFail);
			loadingData = false;
			loadClass();
		}
		private function loadClass():void{
			if(siteStreamItem.isClassLoaded(propertyInfo)){
				parseObject();
			}else{
				var ret:IPendingResult = siteStreamItem.loadClass(propertyInfo);
				ret.success.addHandler(onClassLoadComplete);
			}
		}
		private function onClassLoadComplete(pend:IPendingResult):void{
			pend.success.removeHandler(onClassLoadComplete);
			parseObject();
		}
		private function parseObject():void{
			valueCommited = false;
			isCreating = true;
			var pendingResult:IPendingResult = createObject(propertyInfo,this,parsedLazy);
			pendingResult.success.addHandler(onParsedComplete);
		}
		protected function onParsedComplete(pendingResult:IPendingResult):void{
			pendingResult.success.removeHandler(onParsedComplete);
			if(propertyInfo.value!=null){
				var cast:ISiteStreamParser = propertyInfo.value as ISiteStreamParser
				if(cast){
					if(parentNode)cast.parentParser = parentNode.siteStreamItem;
					else if(_siteStreamItem)cast.parentParser = _siteStreamItem;
					_siteStreamItem = cast;
				}else if(parentNode){
					_siteStreamItem = parentNode.siteStreamItem;
				}
			}
			isCreating = false;
			checkParsed();
		}
		protected function createObject(propertyInfo:IPropertyInfo, propertySetter:IPropertySetter, lazy:Boolean):IPendingResult{
			var pendingResult:IPendingResult = siteStreamItem.createObject(propertyInfo);
			pendingResult.success.addHandler(doChildParse,[propertyInfo, propertySetter, lazy]);
			return pendingResult;
		}
		
		protected function doChildParse(pendingResult:IPendingResult, propertyInfo:IPropertyInfo, propertySetter:IPropertySetter, lazy:Boolean):void{
			pendingResult.success.removeHandler(doChildParse);
			var childProps:Array = siteStreamItem.getChildProperties(propertyInfo);
			for each(var prop:IPropertyInfo in childProps){
				if(prop.isNodeProperty || !lazy){
					var reference:String = siteStreamItem.getNodeReference(prop);
					var propSetter:IPropertySetter;
					if(prop.useNode){
						var childNode:SiteStreamNode = SiteStreamNode.getNew(siteStreamItem, prop);
						//childNode.propertyInfo = prop;
						addChild(childNode);
						if(!reference){
							childNode.beginProcess(siteStreamItem.parseLazily(prop));
						}else{
							childNode.isReference = true;
						}
						if(propertySetter!=this || childNode.isReference){
							propertySetter.addPropertyChild(childNode);
						}
						propSetter = childNode;
					}else{
						var _propSetter:PropertySetter = PropertySetter.getNew(siteStreamItem,prop);
						_propSetter.parentNode = this;
						_propSetter.isReference = (reference!=null);
						if(!_propSetter.isReference){
							if(prop.isObjectProperty){
								if(!prop.isWriteOnly){
									var value:* = propertyInfo.value[prop.propertyName];
									if(value!=null && (!isNaN(value) || !(value is Number))){
										prop.initialValue = value;
									}
								}
							}
							createObject(prop,_propSetter, false);
						}
						propertySetter.addPropertyChild(_propSetter);
						propSetter = _propSetter;
						_propSetter.checkParsed();
					}
					if(reference){
						var referenceNode:ReferenceNodeResolver = new ReferenceNodeResolver(rootNode,reference,propSetter);
						referenceNode.load();
					}
				}
			}
			propertySetter.allParsed; // will trigger event (should be a better way to achieve this)
		}
		public function getChildNode(id:String):SiteStreamNode{
			var iterator:IIterator = children.getIterator();
			var child:SiteStreamNode;
			var ret:SiteStreamNode;
			while(child = iterator.next()){
				if(child.id){
					if(siteStreamItem.compareChildIds(id,child.id)){
						ret = child;
						break;
					}
				}else{
					ret = child.getChildNode(id);
					if(ret)break;
				}
			}
			iterator.release()
			return ret;
		}
		
		override protected function testAllParsed():Boolean{
			var ret:Boolean = false;
			
			if(isReference){
				return true;
			}
			
			if(super.testAllParsed()){
				if(!isCreating){
					ret = true;
					var iterator:IIterator = children.getIterator();
					var child:SiteStreamNode;
					while(child = iterator.next()){
						/*var lazy:Boolean = siteStreamItem.parseLazily(child.propertyInfo);
						if(((lazy && child.dataLoaded && !child.allParsed) || (!lazy && !child.allParsed)) && !child.isReference){*/
						
						if(!child.allParsed){
							ret = false
							break;
						}
					}
					iterator.release();
				}
				if(!ret){
					if(parsedLazy && (!dataLoaded || allParsed)){
						ret = true;
					}
				}
			}
			return ret;
		}
		override protected function testAllResolved():Boolean{
			if(super.testAllResolved() && !parsedLazy){
				var iterator:IIterator = children.getIterator();
				var child:SiteStreamNode;
				var ret:Boolean = true;
				while(child = iterator.next()){
					if((!child.allResolved || !child.valueCommited) && (!siteStreamItem.parseLazily(child.propertyInfo) || child.dataLoaded)){
						ret = false
						break;
					}
				}
				iterator.release();
				return ret;
			}
			return false;
		}
	}
}
