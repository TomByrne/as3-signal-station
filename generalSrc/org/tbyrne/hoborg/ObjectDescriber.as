package org.tbyrne.hoborg
{
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	import org.tbyrne.utils.MetadataConfirmer;
	import org.tbyrne.reflection.ReflectionUtils;
	
	public class ObjectDescriber
	{
		private static const METADATA:Array = ["Property"];
		
		private static var validated:Boolean = false;
		
		private static function validate():void{
			if(!validated){
				if (!MetadataConfirmer.confirm(METADATA,PropertyMetadataTest)){
					trace(MetadataConfirmer.createWarning('ObjectDescriber',METADATA));
				}
				validated = true;
				// add native items
				ObjectDescriber.addNativeObjectDescription(Point,{x:0,y:0},true);
				ObjectDescriber.addNativeObjectDescription(Matrix,{a:0,b:0,c:0,d:0,tx:0,ty:0},true);
				ObjectDescriber.addNativeObjectDescription(Event,{type:""},true);
			}
		}
		
		private static var descriptionCache:Dictionary = new Dictionary(true); // weak so that classes from SWF will not hold up the unloading of the SWF.
		
		protected static function addNativeObjectDescription(classType: Class, props:Object, 
			hasClone:Boolean):void{
			var propDescs:Array = [];
			for(var propName:String in props){
				propDescs.push(new ObjectPropertyDescription(propName,props[propName],true,!hasClone));
			}
			addObjectDescription(new ObjectDescription(classType,propDescs,hasClone));
		}
		public static function addObjectDescription(description:ObjectDescription):void{
			descriptionCache[description.classPath] = description;
		}
		public static function describe(object:*):ObjectDescription{
			validate();
			var objectClass: Class = ReflectionUtils.getClass(object);
			var desc:ObjectDescription = descriptionCache[objectClass];
			if(desc)return desc;
			
			// else generate description
			var typeInfo:XML = ReflectionUtils.describeType(object is String?String:object);
			var objectType: Class = ReflectionUtils.getClass(object);
			var properties:Array = [];
			var members:XMLList = (typeInfo..metadata.(@name=="Property") as XMLList)
			for each(var tag:XML in members){
				var tagName:String = tag.parent().name();
				var isVar:Boolean = (tagName=="variable");
				if(isVar || tagName=="accessor"){
					var name:String = tag.parent().@name;
					var writable:Boolean = (isVar || tag.parent().@access=="readwrite");
					
					var nodes:XMLList = tag.arg.(@key=="toString").(@value=="false");
					var toString:Boolean = (nodes.length()?false:true);
					
					nodes = tag.arg.(@key=="clonable").(@value=="false");
					var clone:Boolean = (nodes.length()?false:true);
					
					nodes = tag.arg.(@key=="deepClone").(@value=="true");
					var deepClone:Boolean = (nodes.length()?true:false);
					
					properties.push(new ObjectPropertyDescription(name,toString,clone,writable,deepClone));
				}
			}
			var implementedInterfaces: Array = ReflectionUtils.getImplementedInterfaces(objectClass);
			var classLineage: Array = ReflectionUtils.getClassLineage(objectClass);
			desc = new ObjectDescription(objectClass);
			desc.properties = properties;
			desc.hasCloneMethod = (typeInfo.method.(@name=="clone").length()==1);
			desc.implementedInterfaces = implementedInterfaces;
			desc.classLineage = classLineage;
			descriptionCache[objectClass] = desc;
			return desc;
		}
		
	}
}

class PropertyMetadataTest{
	[Property]
	public var propertyMeta: Boolean;
}