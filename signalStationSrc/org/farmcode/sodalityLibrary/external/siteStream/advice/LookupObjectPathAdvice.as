package org.farmcode.sodalityLibrary.external.siteStream.advice
{
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodalityLibrary.external.siteStream.adviceTypes.ILookupObjectPathAdvice;
	
	public class LookupObjectPathAdvice extends Advice implements ILookupObjectPathAdvice
	{
		
		[Property(toString="true",clonable="true")]
		public function get lookupObject():Object{
			return _lookupObject;
		}
		public function set lookupObject(value:Object):void{
			_lookupObject = value;
		}
		
		[Property(toString="true",clonable="true")]
		public function get lookupObjectPath():String{
			return _lookupObjectPath;
		}
		public function set lookupObjectPath(value:String):void{
			_lookupObjectPath = value;
		}
		
		private var _lookupObjectPath:String;
		private var _lookupObject:Object;
		
		public function LookupObjectPathAdvice(lookupObject:Object=null){
			super();
			this.lookupObject = lookupObject;
		}
	}
}