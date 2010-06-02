package org.farmcode.reflection
{
	import flash.utils.Dictionary;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getQualifiedSuperclassName;
	
	import org.farmcode.hoborg.ObjectDescriber;
	import org.farmcode.hoborg.ObjectDescription;
	
	public class ReflectionUtils
	{
		/**
		 * Provides a more informative error message and takes care of casting
		 */
		public static function getClassByName(name: String): Class
		{
			var type: Class = null;
			try
			{
				type = getDefinitionByName(name) as Class;
			}
			catch (e: ReferenceError)
			{
				throw new ReferenceError("Class " + name + " is not defined");
			}
			return type;
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
			
			var desc: XML = ReflectionUtils.describeType(targetClass);
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
					var classDef: XML = ReflectionUtils.describeType(def);
					
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
					throw new Error("Couldn't find definition for " + classType);
				}
			}
			
			return containsLineage;
		}
		
		/**
		 * DescribeTypeCache style functionality. DescribeTypeCache has at least one known bug:
		 * 	- if you first request a description like DescribeTypeCache.describeType(MyClass),
		 * 		it will return the Class's definition for all description requests of instances
		 * 		of that class
		 */
		public static function describeType(object: *): XML
		{
			var cacheKey: String = null;
			if (object is String)
			{
				cacheKey = object;
				var klass:Class = getClassByName(cacheKey);
				try{
					object = new klass();
				}catch(e:Error){
					//trace("WARNING: ReflectionUtils.describeType couldn't describe object "+cacheKey);
					return null;
				}
			}
			else if (object is Class)
			{
				cacheKey = getQualifiedClassName(object) + ReflectionUtils.CLASS_SEP + "Class";
			}
			else
			{
				cacheKey = getQualifiedClassName(object);
			}
			
			var type: XML = null;
			if (cacheKey in ReflectionUtils.describeTypeCache)
			{
				type = ReflectionUtils.describeTypeCache[cacheKey];
			}
			else
			{
				type = flash.utils.describeType(object);
				ReflectionUtils.describeTypeCache[cacheKey] = type;
			}
			
			return type;
		}
		
		private static const CLASS_SEP: String = " ";
		private static var describeTypeCache: Dictionary = new Dictionary();
	}
}