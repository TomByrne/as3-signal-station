package org.tbyrne.siteStream.propertyInfo
{
	import org.tbyrne.siteStream.classLoader.IClassInfo;
	import org.tbyrne.siteStream.dataLoader.IDataInfo;
	
	public class PropertyInfo implements IPropertyInfo, IClassInfo, IDataInfo
	{
		// IPropertyInfo implementation
		public function get propertyName():*{
			return _propertyName;
		}
		public function set propertyName(value:*):void{
			_propertyName = value
		}
		public function get value():*{
			return _value;
		}
		public function set initialValue(value:*):void{
			if(!valueSet){
				_value = value;
			}
		}
		public function set value(value:*):void{
			_value = value
			_valueSet = (value!=null);
		}
		public function get valueSet():Boolean{
			return _valueSet;
		}
		public function get useNode():Boolean{
			return _useNode;
		}
		public function set useNode(value:*):void{
			_useNode = value
		}
		public function get isNodeProperty():Boolean{
			return _isNodeProperty;
		}
		public function set isNodeProperty(value:*):void{
			_isNodeProperty = value
		}
		public function get isObjectProperty():Boolean{
			return _isObjectProperty;
		}
		public function set isObjectProperty(value:*):void{
			_isObjectProperty = value
		}
		public function get isWriteOnly():Boolean{
			return _isWriteOnly;
		}
		public function set isWriteOnly(value:*):void{
			_isWriteOnly = value
		}
		
		// IClassInfo implementation
		public function get libraryID():String{
			return _libraryID;
		}
		public function set libraryID(value:String):void{
			_libraryID = value;
		}
		public function get classPath():String{
			return _classPath;
		}
		public function set classPath(value:String):void{
			_classPath = value;
		}
		public function get classRef():Class{
			return _classRef;
		}
		public function set classRef(value:Class):void{
			_classRef = value;
		}
		
		// IDataInfo implementation
		public function get loadedData():XML{
			return _loadedData;
		}
		public function set loadedData(value:XML):void{
			_loadedData = value;
		}
		public function get parentalData():XML{
			return _parentalData;
		}
		public function set parentalData(value:XML):void{
			_parentalData = value;
		}
		
		
		// for use by DefaultParser
		public function get bestData():XML{
			return _loadedData?_loadedData:parentalData;
		}
		public var isClassReference:Boolean;
		public var parentObject:Object;
		
		private var _isWriteOnly:Boolean;
		private var _isObjectProperty:Boolean;
		private var _isNodeProperty:Boolean;
		private var _useNode:Boolean;
		private var _loadedData:XML;
		private var _parentalData:XML;
		private var _valueSet:Boolean;
		private var _value:*;
		private var _libraryID:String;
		private var _classPath:String;
		private var _classRef:Class;
		private var _propertyName:*; // if the parent object is an Array, this might be a Number
		
	}
}