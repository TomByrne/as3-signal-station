package org.tbyrne.siteStream
{
	import flash.utils.Dictionary;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.hoborg.IPoolable;
	import org.tbyrne.hoborg.ObjectPool;
	import org.tbyrne.siteStream.parsers.ISiteStreamParser;
	import org.tbyrne.siteStream.propertyInfo.IPropertyInfo;
	
	public class PropertySetter implements IPropertySetter, IPoolable
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
		
		
		/**
		 * @inheritDoc
		 */
		public function get wasParsed():IAct{
			return (_wasParsed || (_wasParsed = new Act()));
		}
		
		/**
		 * @inheritDoc
		 */
		public function get wasResolved():IAct{
			return (_wasResolved || (_wasResolved = new Act()));
		}
		
		protected var _wasResolved:Act;
		protected var _wasParsed:Act;
		
		
		
		public function get propertyInfo():IPropertyInfo{
			return _propertyInfo;
		}
		public function set propertyInfo(value:IPropertyInfo):void{
			_propertyInfo = value;
		}
		public function get allParsed():Boolean{
			return _allParsed;
		}
		public function get allResolved():Boolean{
			return _allResolved;
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
			checkAllParsed();
		}
		public function get isReference():Boolean{
			return _isReference;
		}
		public function set value(value:*):void{
			propertyInfo.value = value;
			checkAllParsed();
		}
		protected function get valueSet():Boolean{
			return propertyInfo.valueSet;
		}
		
		private var _parentNode:SiteStreamNode;
		private var _propertyInfo:IPropertyInfo;
		protected var valueCommited:Boolean = false;
		protected var _isReference:Boolean = false;
		protected var _allParsed:Boolean = false;
		protected var _allResolved:Boolean = false;
		protected var _siteStreamItem:ISiteStreamParser;
		protected var pendingChildren:Dictionary = new Dictionary();
		protected var pendingRefChildren:Dictionary = new Dictionary();
		
		public var testReference:Boolean;
		
		public function PropertySetter(siteStreamItem:ISiteStreamParser=null, propertyInfo:IPropertyInfo=null){
			/*CONFIG::debug{
				if(!gettingNew && this["constructor"]==PropertySetter)Log.error( "BezierPoint should be created via BezierPoint.getNew");
			}*/
			this._siteStreamItem = siteStreamItem;
			this.propertyInfo = propertyInfo;
		}
		public function addPropertyChild(child:IPropertySetter):void{
			if(!child.allResolved){
				child.wasParsed.addHandler(onChildParsed);
				if(child.isReference){
					// This is high priority to make sure its value is commited immediately when
					// children references are parsed. Otherwise the child parsing triggers the
					// complete in the sitestream request before objects with reference children
					// are commited. Maybe site stream requests or the resolved property need
					// to take in to account the commited status
					
					child.wasResolved.addHandler(onPendingRefResolved);
					
					pendingRefChildren[child] = true;
					testReference = true;
				}else{
					child.wasResolved.addHandler(onPendingResolved);
					pendingChildren[child] = true;
				}
			}
		}
		protected function onChildParsed(child:IPropertySetter):void{
			checkAllParsed();
		}
		protected function onPendingResolved(child:IPropertySetter):void{
			child.wasParsed.removeHandler(onChildParsed);
			child.wasResolved.removeHandler(onPendingResolved);
			delete pendingChildren[child];
			checkAllParsed();
		}
		protected function onPendingRefResolved(child:IPropertySetter):void{
			child.wasParsed.removeHandler(onChildParsed);
			child.wasResolved.removeHandler(onPendingRefResolved);
			delete pendingRefChildren[child];
			checkAllParsed();
		}
		public function checkAllParsed():void{
			var oldVal:Boolean = _allParsed;
			_allParsed = testAllParsed();
			commitValue();
			if(_allParsed){
				if(!oldVal && _wasParsed)_wasParsed.perform(this);
				checkResolved();
			}
		}
		protected function checkResolved():void{
			var oldVal:Boolean = _allResolved;
			_allResolved = testAllResolved();
			if(!oldVal && _allResolved){
				if(_wasResolved)_wasResolved.perform(this);
			}
		}
		protected function commitValue():void{
			if(_allParsed && !valueCommited && (valueSet || !_isReference)){
				/*var allRef:Boolean = true;
				for(var i:* in pendingRefChildren){
					allRef = false;
					break;
				}
				if(allRef){*/
					_siteStreamItem.commitValue(propertyInfo,parentNode);
					valueCommited = true;
				//}
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
			if(isReference){
				return true;
			}
			for(var i:* in pendingChildren){
				var child:IPropertySetter = i;
				if(!child.allParsed){
					return false;
				}
			}
			return valueSet && (propertyInfo!=null);
		}
		protected function testAllResolved():Boolean{
			if(_allParsed && valueCommited){
				var i:*;
				for(i in pendingChildren){
					return false;
				}
				for(i in pendingRefChildren){
					return false;
				}
				return true;
			}
			return false;
		}
		public function release():void{
			pool.releaseObject(this);
		}
	}
}