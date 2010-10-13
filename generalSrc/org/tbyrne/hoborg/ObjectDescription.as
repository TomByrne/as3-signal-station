package org.tbyrne.hoborg
{
	import flash.utils.getQualifiedClassName;
	
	public class ObjectDescription
	{
		public var properties:Array;
		[Property(toString="true", clonable="true")]
		public var hasCloneMethod:Boolean;
		[Property(toString="true", clonable="true")]
		public var implementedInterfaces: Array;
		[Property(toString="true", clonable="true")]
		public var classLineage: Array;
		
		private var _classType: Class;
		private var _classPath: String;
		private var _className: String;
		
		public function ObjectDescription(classType: Class, properties:Array=null,
			hasCloneMethod:Boolean=false, implementedInterfaces: Array = null, 
			classLineage: Array = null)
		{
			this.classType = classType;
			this.properties = properties;
			this.hasCloneMethod = hasCloneMethod;
			this.implementedInterfaces = implementedInterfaces;
			this.classLineage = classLineage;
		}
		
		[Property(toString="true", clonable="true")]
		public function get classType(): Class
		{
			return this._classType;
		}
		public function set classType(value: Class): void
		{
			if (value != this.classType)
			{
				this._classType = value;
				
				var classPath:String = getQualifiedClassName(this.classType);
				classPath = classPath.replace("::", ".");
				this._classPath = classPath;
				this._className = classPath.slice(classPath.lastIndexOf(".") + 1);
			}
		}
		
		public function get classPath(): String
		{
			return this._classPath;
		}
		
		public function get className(): String
		{
			return this._className;
		}
		
		public function toString(): String
		{
			return ReadableObjectDescriber.describe(this);
		}
	}
}