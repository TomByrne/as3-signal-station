package org.tbyrne.siteStream.parsers
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.getQualifiedClassName;
	import flash.xml.XMLNodeKinds;
	
	import org.tbyrne.core.IPendingResult;
	import org.tbyrne.queueing.IQueue;
	import org.tbyrne.queueing.queueItems.functional.MethodCallQI;
	import org.tbyrne.reflection.Deliterator;
	import org.tbyrne.reflection.ReflectionUtils;
	import org.tbyrne.siteStream.SiteStreamNode;
	import org.tbyrne.siteStream.classLoader.IClassInfo;
	import org.tbyrne.siteStream.classLoader.IClassLoader;
	import org.tbyrne.siteStream.dataLoader.IDataInfo;
	import org.tbyrne.siteStream.dataLoader.IDataLoader;
	import org.tbyrne.siteStream.events.SiteStreamErrorEvent;
	import org.tbyrne.siteStream.propertyInfo.IPropertyInfo;
	import org.tbyrne.siteStream.propertyInfo.PropertyInfo;
	
	/**
	 * This class gets used to describe the behaviour of any item being parsed which
	 * does not extend ISiteStreamItem. Only one instance of this class is made (by default).
	 */
	public class DefaultParser extends EventDispatcher implements ISiteStreamParser
	{
		private static const NODE_REFERENCE_EXP:RegExp = /^\{(\S*)\}$/;
		private static const VECTOR_TEST:RegExp = /\[class Vector\.<.*>\]/;
		
		public function get idAttribute():String{
			return _idAttribute;
		}
		public function set idAttribute(value:String):void{
			_idAttribute = value;
		}
		public function get urlAttribute():String{
			return _urlAttribute;
		}
		public function set urlAttribute(value:String):void{
			_urlAttribute = value;
		}
		public function get libraryDelimiter():String{
			return _libraryDelimiter;
		}
		public function set libraryDelimiter(value:String):void{
			_libraryDelimiter = value;
		}
		public function get caseSensitive():Boolean{
			return _caseSensitive;
		}
		public function set caseSensitive(value:Boolean):void{
			_caseSensitive = value;
		}
		public function get dataLoader():IDataLoader{
			return _dataLoader;
		}
		public function set dataLoader(value:IDataLoader):void{
			if(_dataLoader != value){
				if(_dataLoader){
					_dataLoader.removeEventListener(SiteStreamErrorEvent.DATA_FAILURE, bubbleEvent);
				}
				_dataLoader = value;
				if(_dataLoader){
					_dataLoader.addEventListener(SiteStreamErrorEvent.DATA_FAILURE, bubbleEvent, false, 0, true);
				}
			}
		}
		public function get classLoader():IClassLoader{
			return _classLoader;
		}
		public function set classLoader(value:IClassLoader):void{
			if(_classLoader != value){
				if(_classLoader){
					_classLoader.removeEventListener(SiteStreamErrorEvent.CLASS_FAILURE, bubbleEvent);
				}
				_classLoader = value;
				if(_classLoader){
					_classLoader.addEventListener(SiteStreamErrorEvent.CLASS_FAILURE, bubbleEvent, false, 0, true);
				}
			}
		}
		public function get parentParser():ISiteStreamParser{
			return _parentParser;
		}
		public function set parentParser(value:ISiteStreamParser):void{
			if(_parentParser != value){
				_parentParser = value;
				var cast:DefaultParser = value as DefaultParser;
				if(cast){
					if(!dataLoader)dataLoader = cast.dataLoader;
					if(!classLoader)classLoader = cast.classLoader;
					if(!queue)queue = cast.queue;
				}
			}
		}
		public function get queue():IQueue{
			return _queue;
		}
		public function set queue(value:IQueue):void{
			_queue = value;
		}
		
		private var _queue:IQueue;
		private var _caseSensitive:Boolean = false;
		private var _idAttribute:String = "id";
		private var _urlAttribute:String = "url";
		private var _libraryDelimiter:String = "::";
		private var _dataLoader:IDataLoader;
		private var _classLoader:IClassLoader;
		private var _parentParser:ISiteStreamParser;
		
		public function getId(xml:XML):String{
			var list:XMLList = xml.attribute(idAttribute);
			if(list.length()){
				return (list[0] as XML).toString();
			}else{
				return null;
			}
		}
		protected function bubbleEvent(e:Event):void{
			dispatchEvent(e);
		}
		public function isDataLoaded(propertyInfo:IPropertyInfo):Boolean{
			return dataLoader.isDataLoaded(propertyInfo as IDataInfo);
		}
		public function loadData(propertyInfo:IPropertyInfo):IPendingResult{
			var castPropInfo:PropertyInfo = (propertyInfo as PropertyInfo);
			castPropInfo.value = null; // if this was a stub we must clear it up a bit (to avoid early event dispatches)
			var ret:IPendingResult = dataLoader.loadData(propertyInfo as IDataInfo);
			// after data loads, we should reassess/refill the PropertyInfo object (in case the loaded data is different, e.g. uses a different class).
			ret.success.addHandler(onDataLoaded,[propertyInfo]);
			return ret;
		}
		public function onDataLoaded(pending:IPendingResult, propertyInfo:IPropertyInfo):void{
			initPropertyInfo(propertyInfo);
		}
		public function releaseData(propInfo:IPropertyInfo):Boolean{
			var castPropInfo:PropertyInfo = (propInfo as PropertyInfo);
			var hasExtData:Boolean = (castPropInfo.parentalData!=null && castPropInfo.loadedData!=null && castPropInfo.loadedData!=castPropInfo.parentalData);
			if(hasExtData){
				dataLoader.releaseData(propInfo as IDataInfo);
			}
			return hasExtData;
		}
		public function releaseClass(propInfo:IPropertyInfo):void{
			classLoader.releaseClass(propInfo as IClassInfo);
		}
		public function isClassLoaded(propInfo:IPropertyInfo):Boolean{
			var castPropInfo:PropertyInfo = (propInfo as PropertyInfo);
			return classLoader.isClassLoaded(castPropInfo);
		}
		public function loadClass(propInfo:IPropertyInfo):IPendingResult{
			return classLoader.loadClass(propInfo as IClassInfo);
		}
		
		public function createObject(propInfo:IPropertyInfo):IPendingResult{
			var methodCall:MethodCallQI = MethodCallQI.getNew(doCreateObject,[propInfo]);
			queue.addQueueItem(methodCall);
			return methodCall;
		}
		
		public function doCreateObject(propInfo:IPropertyInfo):void{
			var castPropInfo:PropertyInfo = (propInfo as PropertyInfo);
			if(!castPropInfo.classRef && castPropInfo.classPath){
				isClassLoaded(castPropInfo);
			}
			var parsedValue: *;
			var simpleValue:String = castPropInfo.bestData.toString();
			var delay:Boolean = false;
			var complexType: Boolean = false;
			if(castPropInfo.isClassReference){
				parsedValue = castPropInfo.classRef;
			}else{
				switch(castPropInfo.classRef){
					case Class:
						break;
					case XML:
						parsedValue = new XML(simpleValue);
						break;
					case String:
						parsedValue = simpleValue;
						break;
					case Number:
						if (simpleValue.indexOf("0x") == 0) {
							parsedValue = Number(simpleValue);
						}else if (simpleValue.indexOf("#") == 0) {
							parsedValue = Number("0x" + simpleValue.substring(1));
						}else if (simpleValue.toLowerCase() == "nan") {
							parsedValue = NaN;
						} else {
							parsedValue = parseFloat(simpleValue);
						}
						break;
					case int:
					case uint:
						parsedValue = parseInt(simpleValue);
						break;
					case Boolean:
						parsedValue = (simpleValue.toLowerCase()=="true");
						break;
					case Function:
						// TODO: Need to consider package functions, which will look similiar to static functions
						// e.g.		flash.utils.myFunction
						//			flash.utils.FuncClass.myFunction
						var methodSepIndex: int = simpleValue.lastIndexOf(".");
						if (methodSepIndex < 0){
							parsedValue = ReflectionUtils.getFunctionByName(simpleValue);
						}else{
							var functionName: String = simpleValue.substr(methodSepIndex + 1, simpleValue.length);
							var className: String = simpleValue.substring(0, methodSepIndex);
							var methodClass: Class = ReflectionUtils.getClassByName(className);
							try{
								parsedValue = methodClass[functionName] as Function;
							}catch (e: ReferenceError){
								throw new ReferenceError("Function " + simpleValue + " is not defined");
							}
						}
						break;
					default:
						var isArray:Boolean = (castPropInfo.classRef==Array);
						
						if(isArray || VECTOR_TEST.test(String(castPropInfo.classRef))){
							if(castPropInfo.bestData.nodeKind()==XMLNodeKinds.ATTRIBUTE){
								parsedValue = simpleValue.split(",");
								if(!isArray){
									var vec:* = new castPropInfo.classRef();
									for each(var value:* in parsedValue){
										vec.push(value);
									}
									parsedValue = vec;
								}
							}else{
								// if it's an element node and of type Array it gets parsed like a normal object below.
								complexType = true;
							}
						}else{
							complexType = true;
						}
				}
			}
			
			if (complexType)
			{
				if(castPropInfo.classRef){
					parsedValue = castPropInfo.value;
					if(!parsedValue || !(parsedValue is castPropInfo.classRef)){
						parsedValue = new castPropInfo.classRef();
					}
					delay = true;
				}else if(simpleValue && simpleValue.length){
					parsedValue = Deliterator.deliterate(simpleValue);
				}
			}
			propInfo.value = parsedValue;
		}
		public function getNodeReference(propertyInfo:IPropertyInfo):String{
			var castPropInfo:PropertyInfo = (propertyInfo as PropertyInfo);
			var text:String = castPropInfo.bestData.toString();
			var matches:Array = text.match(NODE_REFERENCE_EXP);
			if(matches){
				var reference:String = matches[1];
				if(reference){
					return reference;
				}
			}
			return null;
		}
		public function parseLazily(propertyInfo:IPropertyInfo):Boolean{
			return !isDataLoaded(propertyInfo);
		}
		public function compareChildIds(id1:String, id2:String):Boolean{
			if(_caseSensitive){
				return id1==id2;
			}else{
				if(id1 && id2){
					return id1.toLowerCase()==id2.toLowerCase();
				}else{
					return !id1 && !id2;
				}
			}
		}
		public function createNewPropertyInfo():IPropertyInfo{
			return new PropertyInfo();
		}
		/**
		 * getXMLPropertyInfo returns an item describing a property (as specified by the XML item)
		 * within a parent object. It includes the SWF library URL, property name (within the parent
		 * object) and classpath.
		 */
		protected function getPropertyInfo(xml:XML, parentObject:Object):PropertyInfo{
			var ret:PropertyInfo = new PropertyInfo();
			ret.parentalData = xml;
			ret.parentObject = parentObject;
			initPropertyInfo(ret);
			return ret;
		}
		public function initPropertyInfo(propertyInfo:IPropertyInfo):void{
			var castPropInfo:PropertyInfo = (propertyInfo as PropertyInfo);
			var libraryURL:String;
			var propertyName:String;
			var classPath:String;
			var useNode:Boolean = false;
			var xml:XML = castPropInfo.bestData;
			
			if(xml.nodeKind()==XMLNodeKinds.ATTRIBUTE){
				propertyName = xml.name();
				useNode = xml.toString().match(NODE_REFERENCE_EXP);
			}else if(xml.nodeKind()==XMLNodeKinds.ELEMENT){
				var packageName:String = xml.namespace();
				var index:Number = packageName.indexOf(libraryDelimiter);
				if(index!=-1){
					libraryURL = packageName.slice(0,index);
					packageName = packageName.slice(index+2);
				}
				packageName = cleanPackageName(packageName);
				propertyName = xml.attribute(idAttribute);
				
				// use a node if there is a libraryURL or id
				useNode = (libraryURL && libraryURL.length) || (propertyName && propertyName.length);
				
				if((!propertyName || !propertyName.length) && !packageName){
					propertyName = xml.name();
				}else{
					classPath = xml.localName();
				}
				if(packageName)classPath = packageName+classPath;
			}else{
				// other XML types are not yet supported
				return;
			}
			
			var typeDesc:XML = getTypeDescription(castPropInfo.parentObject);
			
			// Do the check for deep properties. i.e. id="rootProp.parentProp.childProp"
			var varPath: Array = propertyName.split(".");
			var varType:String = null;
			var parentTypeDesc: XML = typeDesc;
			var parentObj: Object = castPropInfo.parentObject;
			while (varPath.length > 0)
			{
				var thisPropName: String = varPath.shift() as String;
				varType = getVariableType(parentTypeDesc, thisPropName);
				if (parentObj == null)
				{
					parentTypeDesc = null;
				}
				else if (varPath.length > 0)
				{
					parentTypeDesc = getTypeDescription(parentObj[thisPropName]);
					parentObj = parentObj[thisPropName];
				}
			}
			if(varType && (!classPath && propertyName && castPropInfo.parentObject)){
				classPath = varType
				if(classPath){
					classPath = classPath.replace("::","."); // clean up class references
				}
			}
			var parentDynamic:Boolean = ((typeDesc.@isDynamic.toString()=="true") && !(castPropInfo.parentObject is Array) && !(castPropInfo.parentObject is String));
			var isID:Boolean = (propertyName==idAttribute);
			var isURL:Boolean = (propertyName==urlAttribute);
			var isClassRef:Boolean = (varType==getQualifiedClassName(Class));
			if(classPath==getQualifiedClassName(Class)){
				isClassRef = true;
				classPath = xml.toString()
			}
			castPropInfo.libraryID = libraryURL;
			castPropInfo.classPath = classPath;
			castPropInfo.isClassReference = isClassRef;
			castPropInfo.isNodeProperty = isID;
			castPropInfo.useNode = useNode;
			castPropInfo.value = null;
			castPropInfo.isWriteOnly = (typeDesc..accessor.(@name==propertyName).@access=="writeonly");
			
			if(!castPropInfo.isObjectProperty || !(castPropInfo.parentObject is Array) || 
				!(castPropInfo.propertyName is int))
			{
				castPropInfo.propertyName = propertyName;
				castPropInfo.isObjectProperty = (varType && varType.length) || parentDynamic;
			}
		}
		/**
		 * cleanPackageName will clean a package name into a format which can then be 
		 * prepended to a class name and reference via ReflectionUtils.getClassByName().
		 */
		private function cleanPackageName(packageName:String):String{
			if(packageName.charAt(packageName.length-1)=="*")packageName = packageName.slice(0,packageName.length-1);
			if(packageName.charAt(packageName.length-1)==".")packageName = packageName.slice(0,packageName.length-1);
			if(packageName.length)packageName+=".";
			return packageName;
		}
		protected function getTypeDescription(object:Object):XML{
			return ReflectionUtils.describeType(object is String?String:object);
		}
		public function commitValue(propertyInfo:IPropertyInfo, node:SiteStreamNode):void{
			var castPropInfo:PropertyInfo = (propertyInfo as PropertyInfo);
			if(castPropInfo.isNodeProperty)_commitValue(propertyInfo,node);
			if(castPropInfo.isObjectProperty)_commitValue(propertyInfo,castPropInfo.parentObject);
		}
		protected function _commitValue(propertyInfo:IPropertyInfo, parentObject: Object):void{
			var prop:* = propertyInfo.propertyName;
			var targetObject: * = parentObject;
			if(prop is String){
				var castProp:String = (prop as String);
				var index:Number;
				while((index = castProp.indexOf("."))!=-1){
					targetObject = targetObject[castProp.substr(0,index)];
					castProp = castProp.substr(index+1);
				}
				prop = castProp;
			}
			if(targetObject){
				targetObject[prop] = propertyInfo.value;
			}else{
				parentObject[propertyInfo.propertyName] = propertyInfo.value;
			}
		}
		
		public function getChildProperties(propertyInfo:IPropertyInfo):Array{
			var castPropInfo:PropertyInfo = (propertyInfo as PropertyInfo);
			var ret:Array = [];
			var arrCount:int = _getChildProperties(ret, castPropInfo.bestData.attributes(), castPropInfo.value,0);
			_getChildProperties(ret, castPropInfo.bestData.elements(), castPropInfo.value,arrCount);
			return ret;
		}
		private function _getChildProperties(array:Array, xmlList:XMLList, parentObject:Object, arrayChildCount:int):int{
			var isArray:Boolean = (parentObject is Array);
			var l:int = xmlList.length();
			for(var i:int=0; i<l; ++i){
				var memberXML:XML = xmlList[i];
				var propInfo:PropertyInfo = getPropertyInfo(memberXML,parentObject);
				if(propInfo){
					if(!propInfo.isObjectProperty){ // parentObject can be null if we're dealing with a stub
						if(isArray && !propInfo.isNodeProperty){
							if(!propInfo.classPath){
								propInfo.classPath = propInfo.propertyName;
							}
							propInfo.propertyName = arrayChildCount++;
							propInfo.isObjectProperty = true;
						}
						else if(propInfo.propertyName!=urlAttribute)
						{
							if(parentObject && (propInfo.propertyName==null || 
								(propInfo.propertyName != null && !propInfo.isNodeProperty)))
							{
								var msg: String = "Couldn't map element \"" + propInfo.propertyName + "\"";
								msg += " to object: "+ memberXML.parent().name();
								Log.error( "DefaultParser._getChildProperties: "+msg);
							}
						}
					}
					if(propInfo.propertyName!=null){
						array.push(propInfo);
					}
				}
			}
			return arrayChildCount;
		}
		/**
		 * getVariableType returns a classpath as found within a class description.
		 * They're in the form 'flash.display::BitmapData'.
		 */
		protected function getVariableType(desc:XML, varName:String):String{
			var xml:XMLList = desc..variable.(@name==varName).@type;
			var type:String = xml.toString();
			if(type && type.length)return type;
			else{
				xml = desc..accessor.(@name==varName).@type;
				if(xml.length()>0){
					type = xml[0].toString();
				}else{
					type = null;
				}
				if(type && type.length)return type;
				else return null;
			}
		}
		override public function dispatchEvent(event:Event):Boolean{
			if(parentParser){
				return parentParser.dispatchEvent(event);
			}else{
				return super.dispatchEvent(event);
			}
		}
	}
}