package org.tbyrne.reflection
{
	import flash.utils.Dictionary;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getQualifiedSuperclassName;
	
	import org.tbyrne.hoborg.ObjectDescriber;
	import org.tbyrne.hoborg.ObjectDescription;
	
	public class ReflectionUtils
	{
		/**
		 * Provides a more informative error message and takes care of casting
		 */
		// @todo cache results
		public static function getClassByName(name: String): Class
		{
			var type: Class = null;
			try
			{
				type = getDefinitionByName(name) as Class;
			}
			catch (e: ReferenceError)
			{
				throw new ReferenceError("Class '" + name + "' is invalid or undefined");
			}
			return type;
		}
		public static function doesClassExist(name: String): Boolean
		{
			try{
				getDefinitionByName(name);
			}catch (e: ReferenceError){
				return false;
			}
			return true;
		}
		
		
		public static function getFunctionByName(name: String): Function
		{
			var func: Function = null;
			try
			{
				func = getDefinitionByName(name) as Function;
			}
			catch (e: ReferenceError)
			{
				throw new ReferenceError("Function " + name + " is not defined");
			}
			return func;
		}
		
		// TODO: Theres a bug in this, consider classes at the bottom of files; internal file classes
		// with the same name (see sodalityprojectsettingsvalidator). Their qualified class names
		// are the same
		public static function getClass(subject: Object): Class
		{
			var result: Class = null;
			if (subject != null)
			{
				result = ReflectionUtils.getClassByName(getQualifiedClassName(subject));
			}
			return result;
		}
		
		// TODO: Cache this result?
		public static function isClassInstanceOf(targetType: Class, parentType: Class): Boolean
		{
			var typeMatch: Boolean = false;
			if (targetType == parentType)
			{
				typeMatch = true;
			}
			else
			{
				var desc: ObjectDescription = ObjectDescriber.describe(targetType);
				
				// Check class lineage
				if (desc.classLineage.indexOf(parentType) >= 0)
				{
					typeMatch = true;
				}
				else
				{
					// Check interface lineage
					if (desc.implementedInterfaces.indexOf(parentType) >= 0)
					{
						typeMatch = true;
					}
				}
			}
			return typeMatch;
		}
		
		public static function getImplementedInterfaces(targetClass: Class): Array
		{
			var lineage: Array = new Array();
			
			var desc: XML = ReflectionUtils.describeClass(targetClass);
			for each (var interfaceXML: XML in desc.factory.implementsInterface)
			{
				var interfaceName: String = interfaceXML.@type;
				var interfaceType: Class = getDefinitionByName(interfaceName) as Class;
				lineage.push(interfaceType);
			}
			
			return lineage;
		}
		
		public static function getClassLineage(targetClass: Class, terminalClass: Class = null): Array
		{
			var classLineage: Array = new Array();
			var klass: Class = targetClass;
			var atInheritanceRoot: Boolean = false;
			while(!atInheritanceRoot)
			{
				if (klass == null)
				{
					atInheritanceRoot = true;
				}
				else if (klass == terminalClass)
				{
					classLineage.push(klass);
					atInheritanceRoot = true;
				}
				else
				{
					classLineage.push(klass);
					var superClass: String = getQualifiedSuperclassName(klass);
					if (superClass == null)
					{
						klass = null;
					}
					else
					{
						klass = (getDefinitionByName(superClass) as Class);
					}
				}
			}
			return classLineage;
		}
		public static function isClassDynamic(object:*): Boolean{
			var typeDesc:XML
			if(object is Class){
				typeDesc = describeObject(new object());
			}else{
				typeDesc = describeObject(object);
			}
			return String(typeDesc.@isDynamic)=="true";
		}
		
		public static function getClassName(obj:*): String{
			var klass:Class;
			if(obj is Class)klass = (obj as Class);
			else klass = ReflectionUtils.getClass(obj);
			var className:String = getQualifiedClassName(klass);
			var classPackageSepIndex: int = className.indexOf("::");
			if (classPackageSepIndex >= 0) {
				return className.substring(classPackageSepIndex+2);
			} else {
				return className;
			}
		}
		public static function getClassPath(obj:*): String{
			var klass:Class;
			if(obj is Class)klass = (obj as Class);
			else klass = ReflectionUtils.getClass(obj);
			var className:String = getQualifiedClassName(klass);
			return className.replace("::",".");
		}
		
		// TODO: Functions should use class/interface references. Possibly with other wrapper functions
		// to use with just names
		/**
		 * Finds if the given class type inherits from the given target class type. The
		 * type description should be of the form of a qualified class name. 
		 * 		
		 * 		e.g. my.package.name::ClassName
		 * 
		 * @see flash.utils.getQualifiedClassName
		 * 
		 * @param	classType	The class type to check the type of
		 * @param	targetClassType		The class to check for in classType's lineage
		 */
		public static function classTypeInheritsFrom(classType: String, targetClassType: String): Boolean
		{
			return ReflectionUtils.classTypeLineageContains(classType, targetClassType, false);
		}
		
		public static function classTypeImplements(classType: String, targetInterfaceType: String): Boolean
		{
			return ReflectionUtils.classTypeLineageContains(classType, targetInterfaceType, true);
		}
		
		private static function classTypeLineageContains(classType: String, lineageType: String, 
			isInterface: Boolean = false): Boolean
		{
			var containsLineage: Boolean = (classType == lineageType);
			
			if (!containsLineage)
			{
				var lineageNodeName: String = "extendsClass";
				if (isInterface)
				{
					lineageNodeName = "implementsInterface";
				}
				
				try
				{
					var def: Class = getDefinitionByName(classType) as Class;
					var classDef: XML = ReflectionUtils.describeClass(def);
					
					var lineageNodes: XMLList = classDef[lineageNodeName];
					for each (var lNode: XML in lineageNodes)
					{
						if (lNode.attribute("type") == lineageType)
						{
							containsLineage = true;
							break;
						}
					}
				}
				catch (error: ReferenceError)
				{
					Log.error( "ReflectionUtils.classTypeLineageContains: Couldn't find definition for " + classType);
				}
			}
			
			return containsLineage;
		}
		
		public static function describeType(object: *): XML
		{
			if(object is Class){
				return describeClass(object as Class);
			}else{
				return describeObject(object);
			}
		}
		public static function describeClass(object:Class): XML
		{
			var cacheKey: String = getQualifiedClassName(object);
			
			if (cacheKey in ReflectionUtils.describeClassCache){
				return ReflectionUtils.describeClassCache[cacheKey];
			}else{
				var type:XML = flash.utils.describeType(object);
				ReflectionUtils.describeClassCache[cacheKey] = type;
				return type;
			}
		}
		public static function describeObject(object: *): XML
		{
			if(object is Class){
				Log.error("Use describeClass to inspect classes");
			}
			var cacheKey: String = getQualifiedClassName(object);
			
			if (cacheKey in ReflectionUtils.describeObjectCache){
				return ReflectionUtils.describeObjectCache[cacheKey];
			}else{
				var type:XML = flash.utils.describeType(object);
				ReflectionUtils.describeObjectCache[cacheKey] = type;
				return type;
			}
		}
		
		private static var describeClassCache: Dictionary = new Dictionary();
		private static var describeObjectCache: Dictionary = new Dictionary();
		
		
		/**
		 * Function should have a signature:
		 * function(parentObject:*, value:*, memberName:String, isMethod:Boolean, definedBy:Class, definedType:Class, ... additionalParams):Boolean;
		 * 
		 * By returning true the calls will be aborted.
		 */
		public static function callForMembers(object:*, func:Function, props:Boolean, methods:Boolean, inheritedMembers:Boolean=true, additionalParams:Array=null, doDynamic:Boolean=true, doArray:Boolean=true):void{
			var type:Class = getClass(object);
			var i:int;
			var doneProps:Dictionary = new Dictionary();
			
			var inheritance:Array;
			if(inheritedMembers){
				inheritance = getClassLineage(type);
				for(i=inheritance.length-1; i>=0; --i){ // traverse from super to subclass
					var type2:Class = inheritance[i];
					if(_callForMembers(type2, object, func, props, methods, inheritedMembers, additionalParams, doneProps)){
						return;
					}
				}
			}else{
				_callForMembers(type, object, func, props, methods, inheritedMembers, additionalParams, doneProps);
			}
			
			var doDyn:Boolean = (doDynamic && ReflectionUtils.isClassDynamic(object));
			
			var params:Array;
			if(doDyn || doArray){
				params = [object, null, null, true, type, null];
				if(additionalParams){
					params = params.concat(additionalParams);
				}
			}
			
			if(doDyn){
				for(var j:* in object){
					if(!doneProps[i]){
						doneProps[j] = true;
						params[1] = object[j];
						params[2] = j;
						if(func.apply(null,params)){
							return;
						}
					}
				}
			}else if(doArray){
				const VECTOR_TEST:RegExp = /\[class Vector\.<.*>\]/;
				
				var arrayCheck:Boolean = (type==Array || VECTOR_TEST.test(String(type)));
				if(arrayCheck){
					for(i=0; i<object.length; ++i){
						if(!doneProps[i]){
							doneProps[i] = true;
							params[1] = object[i];
							params[2] = i;
							if(func.apply(null,params)){
								return;
							}
						}
					}
				}
			}
		}
		
		private static function _callForMembers(type:Class, object:*, func:Function, props:Boolean, methods:Boolean, inheritedMembers:Boolean, additionalParams:Array, doneProps:Dictionary):Boolean{
			var typeDesc:XML = describeClass(type);
			
			var params:Array = [object, null, null, null, type, null];
			if(additionalParams){
				params = params.concat(additionalParams);
			}
			
			if(props){
				params[3] = false;
				if(_doMemberCalls(func,object,params,typeDesc.factory.children().(name()=="variable" || (name()=="accessor" && @access.toString()=="readwrite")),doneProps)){
					return true;
				}
			}
			if(methods){
				params[3] = true;
				if(_doMemberCalls(func,object,params,typeDesc.factory.method,doneProps)){
					return true;
				}
			}
			return false;
		}
		
		private static function _doMemberCalls(func:Function, object:*, params:Array, memList:XMLList, doneProps:Dictionary):Boolean{
			for each(var memXML:XML in memList){
				var memberName:String = memXML.@name;
				if(!doneProps[memberName]){
					var definedType:Class = getClassByName(memXML.@type);
					
					doneProps[memberName] = true;
					params[1] = object[memberName];
					params[2] = memberName;
					params[5] = definedType;
					if(func.apply(null,params)){
						return true;
					}
				}
			}
			return false;
		}
	}
	
}