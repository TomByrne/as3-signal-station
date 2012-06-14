package org.tbyrne.siteStream.serialiser
{
	import flash.utils.Dictionary;
	import flash.utils.describeType;
	
	import org.tbyrne.data.core.BooleanData;
	import org.tbyrne.data.core.StringData;
	import org.tbyrne.reflection.ReflectionUtils;

	public class SiteStreamSerialiser
	{
		private static const VECTOR_TEST:RegExp = /\[class Vector\.<.*>\]/;
		
		public static function applyStandardTypeRules(siteStreamSerialiser:SiteStreamSerialiser):void{
			var typeRules:TypeRules = new TypeRules(["length"]);
			siteStreamSerialiser.addTypeRules(Array,typeRules);
		}
		
		public function get idAttribute():String{
			return _idAttribute;
		}
		public function set idAttribute(value:String):void{
			_idAttribute = value;
		}
		
		private var _idAttribute:String = "id";
		
		
		private var _typeRules:Dictionary = new Dictionary();
		
		public function addTypeRules(type:Class, typeRules:ITypeRules):void{
			_typeRules[type] = typeRules;
		}
		public function removeTypeRules(type:Class):void{
			delete _typeRules[type];
		}
		public function serialise(object:*):XML{
			return _serialiseNode(object,new Dictionary(),null,null,null,null);
		}
		
		
		
		private function _serialise(object:Object, references:Dictionary, parentXML:XML, topXML:XML, parentTypeRules:ITypeRules, memberName:String):void{
			var refXML:XML = references[object];
			if(refXML){
				var referenceStr:String = createReferenceString(refXML);
				if(memberName){
					parentXML.@[memberName] = referenceStr;
				}else{
					parentXML.appendChild(new XML("<String>"+referenceStr+"</String>"));
				}
			}else{
				var isObj:Boolean = (object!=null && typeof(object)=="object");
				var type:Class = ReflectionUtils.getClass(object);
				if(memberName && (!isObj || checkSimpleChildren(object,type))){
					parentXML.@[memberName] = _serialiseSimple(object,_typeRules[object],memberName);
				}else{
					_serialiseNode(object,references,topXML,parentXML,parentTypeRules,memberName);
				}
			}
		}
		
		private function createReferenceString(refXML:XML):String{
			var ret:String = "";
			while(refXML.parent()){
				var nodeId:String = refXML.attribute(_idAttribute);
				if(!nodeId){
					nodeId = refXML.localName();
					var idInd:int = 0;
					var siblings:XMLList = refXML.parent().children();
					while(siblings.(attribute(_idAttribute)==nodeId).length()){
						nodeId = refXML.localName()+String(idInd);
						++idInd;
					}
					refXML.@[_idAttribute] = nodeId
				}
				if(ret.length){
					ret = nodeId+"/"+ret;
				}else{
					ret = nodeId;
				}
				refXML = refXML.parent();
			}
			var rootId:String = refXML.attribute(_idAttribute);
			if(rootId){
				ret = rootId+"/"+ret;
			}
			return "{"+ret+"}";
		}
		
		private function _serialiseNode(object:*, references:Dictionary, topXML:XML, parentXML:XML, parentTypeRules:ITypeRules, memberName:String):XML{
			var ns:Namespace;
			var foundNS:Boolean;
			
			var type:Class = ReflectionUtils.getClass(object);
			var className:String = ReflectionUtils.getClassName(type);
			var classPath:String = ReflectionUtils.getClassPath(type);
			
			var simpleValue:String;
			var tagName:String;
			
			var isObj:Boolean = (object!=null && typeof(object)=="object");
			
			if(isObj){
				
				var typeRules:ITypeRules = _typeRules[type];
				if(typeRules && !typeRules.doSerialise(object)){
					return null;
				}
					
				if(className==classPath){
					tagName = className;
				}else{
					classPath = classPath.substr(0,classPath.lastIndexOf("."));
					var usedNSs:Dictionary;
					if(topXML){
						usedNSs = new Dictionary();
						for each(ns in topXML.namespaceDeclarations()){
							if(ns.uri == classPath){
								foundNS = true;
								break;
							}
							usedNSs[ns.prefix] = true;
						}
					}
					if(!foundNS){
						var prefix:String = classPath.substr(classPath.lastIndexOf(".")+1);
						if(usedNSs){
							var prefixI:int = 0;
							while(usedNSs[prefix]){
								++prefixI;
								prefix = classPath.substr(0,classPath.lastIndexOf(".")-1)+prefixI;
							}
						}
						ns = new Namespace(prefix,classPath);
					}
					tagName = ns.prefix+":"+className;
				}
				
			}else{
				tagName = className;
				simpleValue = _serialiseSimple(object,parentTypeRules,memberName);
			}
			var openTag:String;
			if(memberName && memberName.length){
				openTag = "<"+tagName+" id='"+memberName+"'";
			}else{
				openTag = "<"+tagName;
			}
			if(ns){
				openTag += " xmlns:"+ns.prefix+"='"+ns.uri+"'>";
			}else{
				openTag +=">";
			}
			var ret:XML = new XML(openTag+(simpleValue?simpleValue:"")+"</"+tagName+">");
			if(parentXML)parentXML.appendChild(ret); // must append immediately for reference children to work
			
			if(!topXML){
				topXML = ret;
			}else if(ns && !foundNS){
				topXML.addNamespace(ns);
			}
			
			if(isObj){
				references[object] = ret;
				ReflectionUtils.callForMembers(object,createChildNodes,true,false,true,[ret,references,typeRules,topXML,type]);
			}
			
			
			return ret;
		}
		private function createChildNodes(parentObject:*, value:*, memberName:*, isMethod:Boolean, definedBy:Class, definedType:Class, parentXML:XML, references:Dictionary, parentTypeRules:ITypeRules, topXML:XML, type:Class):Boolean{
			if(checkIgnore(type, memberName, value))return false;
			
			_serialise(value, references, parentXML, topXML, parentTypeRules, memberName is String?memberName:null);
			
			return false;
		}
		
		private function createLiteralString(object:*, arrayCheck:Boolean):String{
			var typeRules:ITypeRules = _typeRules[object];
			if(arrayCheck){
				var ret:String = "[";
				for(var i:int=0; i<object.length; ++i){
					var value:* = object[i];
					ret += _serialiseSimple(value,typeRules,null);
					if(i<object.length-1){
						ret += ",";
					}
				}
				ret += "]";
				return ret;
			}else{
				var type:Class = ReflectionUtils.getClass(object);
				var objectStr:StringData = new StringData("{");
				ReflectionUtils.callForMembers(object,createObjectStr,true,false,true,[objectStr,typeRules,type],true,false);
				var str:String = objectStr.stringValue;
				if(str.length>1)str = str.substr(0,str.length-1);
				return str+"}";
			}
		}
		
		private function createObjectStr(parentObject:*, value:*, memberName:*, isMethod:Boolean, definedBy:Class, definedType:Class, stringData:StringData, typeRules:ITypeRules, type:Class):Boolean{
			if(checkIgnore(type, memberName, value))return false;
			
			var str:String = _serialiseSimple(value,typeRules,memberName is String?memberName:null);
			if(str){
				stringData.stringValue += str+",";
			}
			return false;
		}
		
		private function checkIgnore(type:Class, memberName:*, value:*):Boolean
		{
			var typeRules:ITypeRules = _typeRules[type];
			if(typeRules){
				if(typeRules.ignoreProps && typeRules.ignoreProps.indexOf(memberName)!=-1){
					return true;
				}else if(typeRules.defaultProps){
					var defValue:* = typeRules.defaultProps[memberName];
					if(defValue==value ||(isNaN(defValue) && typeof(defValue)=="number" && isNaN(value) && typeof(value)=="number")){
						return true;
					}
				}
			}
			return false;
		}
		private function _serialiseSimple(object:*, typeRules:ITypeRules, memberName:String):String{
			
			if(object==null)return "";
			
			switch(typeof(object)){
				case "number":
					if(isNaN(object)){
						return "NaN";
					}else if(typeRules && typeRules.hexNumberProps.indexOf(memberName)!=-1){
						return "#"+(object as Number).toString(16);
					}else{
						return String(object);
					}
					break;
				case "string":
					return object;
					break;
				case "boolean":
					return object?"true":"false";
					break;
				default:
					var type:Class = ReflectionUtils.getClass(object);
					var arrayCheck:Boolean = (type==Array || VECTOR_TEST.test(String(type)));
					return createLiteralString(object, arrayCheck);
			}
		}
		
		private function checkSimpleChildren(object:*, type:Class):Boolean{
			if(type==Object || type==Array || VECTOR_TEST.test(String(type))){
				var typeRules:ITypeRules = _typeRules[object];
				var isSimple:BooleanData = new BooleanData(true);
				ReflectionUtils.callForMembers(object,checkIsSimple,true,false,true,[isSimple,type]);
				return isSimple.booleanValue;
			}else{
				return false;
			}
		}
		
		private function checkIsSimple(parentObject:*, value:*, memberName:*, isMethod:Boolean, definedBy:Class, definedType:Class, isSimple:BooleanData, type:Class):Boolean{
			if(checkIgnore(type, memberName, value))return false;
			
			var typeRules:ITypeRules = _typeRules[value];
			
			if(typeof(value)=="object"){
				var type:Class = ReflectionUtils.getClass(value);
				typeRules = _typeRules[type];
				if(typeRules && typeRules.allowTypeAsLiteral){
					return false;
				}else if(type==definedType || type==Object || type==Array || VECTOR_TEST.test(String(type))){
					if(!checkSimpleChildren(value,type)){
						isSimple.booleanValue = false;
						return true;
					}
				}else{
					isSimple.booleanValue = false;
					return true;
				}
			}
			return false
		}
	}
}