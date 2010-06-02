package org.farmcode.hoborg
{
	public class ObjectPropertyDescription
	{
		public var propertyName:String;
		public var toString:Boolean=true;
		public var clone:Boolean;
		public var writable:Boolean=true;
		public var deepClone:Boolean=false;
		
		public function ObjectPropertyDescription(propertyName:String, toString:Boolean=true, clone:Boolean=false, writable:Boolean=true, deepClone:Boolean=false){
			this.propertyName = propertyName;
			this.toString = toString;
			this.clone = clone;
			this.writable = writable;
			this.deepClone = deepClone;
		}
	}
}