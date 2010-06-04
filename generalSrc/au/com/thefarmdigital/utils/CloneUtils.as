package au.com.thefarmdigital.utils
{
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.filters.BitmapFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import flash.xml.XMLNode;
	
	import org.farmcode.compiler.MetadataConfirmer;
	import org.farmcode.reflection.ReflectionUtils;
	
	/**
	 * Clones objects using the values from Properties tagged with [Clonable] Metadata.
	 * Optionally you can include the deep property int he metadata to clone the property also.
	 * e.g. [Clonable(deep=true)]
	 */
	// TODO: Consider how to implement deep for another level down for native objs. e.g.
	// how to specify to clone all the items in an array or dictionary as well as clone the
	// array/dict itself
	public class CloneUtils
	{
		private static const METADATA: Array = ["Clonable"];
		
		protected static const TO_STRING_RECURSION_LIMIT: uint = 0xff;
		protected static var toStringRecursion: uint = 0;
		
		private static var validated: Boolean = false;
		
		public static function clone(subject: Object): Object 
		{
			if (!CloneUtils.validated)
			{
				if (!MetadataConfirmer.confirm(METADATA,ClonableMetadataTest)){
					trace(MetadataConfirmer.createWarning("CloneUtils",METADATA));
				}
				CloneUtils.validated = true;
			}
			
			if (subject == null)
			{
				throw new ArgumentError("Cannot clone null value");
			}
			var ret: * = null;
			var subjClass: Class = ReflectionUtils.getClass(subject);
			// TODO: Consider how to clone objects which subclass Event. BitmapData, etc. They could
			// Have clonable tags for cloning, or could override clone function to do custom cloning
			switch (subjClass)
			{
				case	String:
				case	int:
				case	uint:
				case	Boolean:
				case	Number:
					ret = subject;
					break;
				case	Event:
					var subjectEvent: Event = subject as Event;
					ret = subjectEvent.clone();
					break;
				case	Matrix:
					var subjectMatrix: Matrix = subject as Matrix;
					ret = subjectMatrix.clone();
					break;
				case	Rectangle:
					var subjectRectangle: Rectangle = subject as Rectangle;
					ret = subjectRectangle.clone();
					break;
				case	Point:
					var subjectPoint: Point = subject as Point;
					ret = subjectPoint.clone();
					break;
				case	BitmapFilter:
					var subjectFilter: BitmapFilter = subject as BitmapFilter;
					ret = subjectFilter.clone();
					break;
				case	XMLNode:
					var subjectNode: XMLNode = subject as XMLNode;
					ret = subjectNode.cloneNode(true);
					break;
				case	Array:
					var subjectArr: Array = subject as Array;
					var newArr: Array = new Array(subjectArr.length);
					for (var i: uint = 0; i < subjectArr.length; ++i)
					{
						newArr[i] = subjectArr[i];
					}
					ret = newArr;
					break;
				case	Dictionary:
					var subjectDict: Dictionary = subject as Dictionary;
					var cloneDict: Dictionary = new Dictionary();
					for (var key: String in subjectDict)
					{
						cloneDict[key] = subjectDict[key];
					}
					ret = cloneDict;
					break;
				case	BitmapData:
					var subjectBMD: BitmapData = subject as BitmapData;
					ret = subjectBMD.clone();
					break;
				default:
					var typeInfo:XML = ReflectionUtils.describeType(subject);
					ret = new subjClass();
					
					// WTF, if use props = null  this line, if use the result directly (see for each loop below)
					// its fine. Uncomment trace to see what is meant
					//var props: XMLList = (typeInfo..metadata.(@name=="Clonable") as XMLList);
					//trace("type info = " + props + "\n\n" + (typeInfo..metadata.(@name=="Clonable") as XMLList));

					for each(var tag:XML in (typeInfo..metadata.(@name=="Clonable") as XMLList)){
						var tagName:String = tag.parent().name();
						if(tagName=="variable" || (tagName=="accessor" && tag.parent().@access=="readwrite"))
						{
							var name:String = tag.parent().@name;
							var targetValue: * = subject[name];
							var deepStr: String = tag.arg.(@key == "deep").@value;
							if (deepStr != '' && deepStr.toLowerCase() == "true" && targetValue != null)
							{
								targetValue = CloneUtils.clone(targetValue);
							}
							ret[name] = targetValue;
						}
					}
			}
			return ret;
		}
		
		public static function getClonableProperties(subject: Object): Array
		{
			var props: Array = new Array();
			var typeInfo:XML = ReflectionUtils.describeType(subject);
			var klass:Class = ReflectionUtils.getClass(subject);
			var propNodes:XMLList = typeInfo..metadata.(@name=="Clonable");
			for each(var tag:XML in propNodes)
			{
				var tagName:String = tag.parent().name();
				if(tagName=="variable" || (tagName=="accessor" && tag.parent().@access=="readwrite"))
				{
					var name:String = tag.parent().@name;
					props.push(name);
				}
			}
			return props;
		}
		
		public static function toString(subject:Object, valueCharLimit: int = -1): String
		{
			var propNames: Array = CloneUtils.getClonableProperties(subject);
			return CloneUtils.toStringManual(subject, propNames, valueCharLimit);
		}
		
		public static function toStringManual(subject: Object, propNames: Array, valueCharLimit: int = -1): String
		{
			CloneUtils.toStringRecursion++;
			if (CloneUtils.toStringRecursion > CloneUtils.TO_STRING_RECURSION_LIMIT)
			{
				CloneUtils.toStringRecursion--;
				throw new Error("Maximum recursion reached for CloneUtils.toString function");
			}
			else
			{
				var props:String = "";
				for (var i: uint = 0; i < propNames.length; ++i)
				{
					var pName: String = propNames[i];
					var value: String = subject[pName];
					if (valueCharLimit >= 0)
					{
						value = value.substr(0, valueCharLimit);
					}
					props += " "+pName+":"+value;
				}
				CloneUtils.toStringRecursion--;
			}
			return "["+ReflectionUtils.getClassName(subject)+props + "]";
		}
	}
}
class ClonableMetadataTest
{
	[Clonable]
	public var cloneMeta: Boolean;
}