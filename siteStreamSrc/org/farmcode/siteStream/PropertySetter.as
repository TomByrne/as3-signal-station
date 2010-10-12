package org.farmcode.siteStream
{
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	import org.farmcode.hoborg.IPoolable;
	import org.farmcode.hoborg.ObjectPool;
	import org.farmcode.siteStream.events.SiteStreamEvent;
	import org.farmcode.siteStream.parsers.ISiteStreamParser;
	import org.farmcode.siteStream.propertyInfo.IPropertyInfo;
	
	[Event(name="parsed",type="org.farmcode.siteStream.SiteStreamEvent")]
	public class PropertySetter extends EventDispatcher implements IPropertySetter, IPoolable
	{
		/*CONFIG::debug{
			private static var gettingNew:Boolean;
		}*/
		private static const pool:ObjectPool = new ObjectPool(PropertySetter);
		public static function getNew(siteStreamItem:ISiteStreamParser, propertyInfo:IPropertyInfo):PropertySetter{
			/*CONFIG::debug{
				gettingNew = true;
			}*/
			var ret:PropertySetter = pool.takeObject();
			/*CONFIG::debug{
				gettingNew = false;
			}*/
			ret.siteStreamItem = siteStreamItem;
			ret.propertyInfo = propertyInfo;
			return ret;
		}
		
		public function get propertyInfo():IPropertyInfo{
			return _propertyInfo;
		}
		public function set propertyInfo(value:IPropertyInfo):void{
			_propertyInfo = value;
		}
		public function get allParsed():Boolean{
			checkParsed();
			return _allParsed;
		}
		public function get siteStreamItem():ISiteStreamParser{
			return _siteStreamItem;
		}
		public function set siteStreamItem(value:ISiteStreamParser):void{
			_siteStreamItem = value;
		}
		public function set parentNode(value:SiteStreamNode):void{
			_parentNode = value;
		}
		public function get parentNode():SiteStreamNode{
			return _parentNode;
		}
		public function set isReference(value:Boolean):void{
			_isReference = value;
		}
		public function get isReference():Boolean{
			return _isReference;
		}
		public function set value(value:*):void{
			propertyInfo.value = value;
			checkParsed();
		}
		protected function get valueSet():Boolean{
			return propertyInfo.valueSet;
		}
		
		private var _parentNode:SiteStreamNode;
		private var _propertyInfo:IPropertyInfo;
		protected var valueCommited:Boolean = false;
		protected var _isReference:Boolean = false;
		protected var _allParsed:Boolean = false;
		protected var _siteStreamItem:ISiteStreamParser;
		protected var pendingChildren:Dictionary = new Dictionary();
		protected var pendingRefChildren:Dictionary = new Dictionary();
		
		public function PropertySetter(siteStreamItem:ISiteStreamParser=null, propertyInfo:IPropertyInfo=null){
			/*CONFIG::debug{
				if(!gettingNew && this["constructor"]==PropertySetter)throw new Error("WARNING: BezierPoint should be created via BezierPoint.getNew()");
			}*/
			this._siteStreamItem = siteStreamItem;
			this.propertyInfo = propertyInfo;
		}
		public function addPropertyChild(child:IPropertySetter):void{
			if(child.isReference){
				// This is high priority to make sure its value is commited immediately when
				// children references are parsed. Otherwise the child parsing triggers the
				// complete in the sitestream request before objects with reference children
				// are commited. Maybe site stream requests or the resolved property need
				// to take in to account the commited status
				child.addEventListener(SiteStreamEvent.PARSED, onPendingRefParsed, false, int.MAX_VALUE);
				pendingRefChildren[child] = true;
			}else{
				if(!child.allParsed){
					child.addEventListener(SiteStreamEvent.PARSED, onPendingParsed, false, int.MAX_VALUE);
					pendingChildren[child] = true;
				}
			}
		}
		protected function onPendingParsed(e:SiteStreamEvent):void{
			var child:IPropertySetter = (e.target as IPropertySetter);
			child.removeEventListener(SiteStreamEvent.PARSED, onPendingParsed);
			delete pendingChildren[child];
			checkParsed();
		}
		protected function onPendingRefParsed(e:SiteStreamEvent):void{
			var child:IPropertySetter = (e.target as IPropertySetter);
			child.removeEventListener(SiteStreamEvent.PARSED, onPendingParsed);
			delete pendingRefChildren[child];
			checkParsed();
		}
		public function checkParsed():void{
			var oldVal:Boolean = _allParsed;
			_allParsed = testAllParsed();
			commitValue();
			if(!oldVal && _allParsed){
				dispatchEvent(new SiteStreamEvent(SiteStreamEvent.PARSED));
			}
		}
		protected function commitValue():void{
			if(_allParsed && !valueCommited && (valueSet || !_isReference)){
				var allRef:Boolean = true;
				for(var i:* in pendingRefChildren){
					allRef = false;
					break;
				}
				if(allRef){
					_siteStreamItem.commitValue(propertyInfo,parentNode);
					valueCommited = true;
				}
			}
		}
		protected function unloadData():void{
			valueCommited = false;
			_allParsed = false;
			
			for(var i:* in pendingChildren){
				i.release();
			}
			pendingChildren = new Dictionary();
			
			for(i in pendingRefChildren){
				i.release();
			}
			pendingRefChildren = new Dictionary();
		}
		public function reset():void{
			unloadData();
			parentNode = null;
			value = null;
			siteStreamItem = null;
			propertyInfo = null;
			isReference = false;
		}
		protected function testAllParsed():Boolean{
			for(var i:* in pendingChildren){
				return false;
			}
			return valueSet && (propertyInfo!=null);
		}
		public function release():void{
			pool.releaseObject(this);
		}
	}
}