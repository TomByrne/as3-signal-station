package org.farmcode.actLibrary.external.siteStream.acts
{
	import org.farmcode.actLibrary.external.siteStream.actTypes.ILookupObjectPathAct;
	import org.farmcode.acting.acts.UniversalAct;
	
	public class LookupObjectPathAct extends UniversalAct implements ILookupObjectPathAct
	{
		public function get lookupObject():Object{
			return _lookupObject;
		}
		public function set lookupObject(value:Object):void{
			_lookupObject = value;
		}
		public function get lookupObjectPath():String{
			return _lookupObjectPath;
		}
		public function set lookupObjectPath(value:String):void{
			_lookupObjectPath = value;
		}
		
		private var _lookupObjectPath:String;
		private var _lookupObject:Object;
		
		public function LookupObjectPathAct(lookupObject:Object=null){
			super();
			this.lookupObject = lookupObject;
		}
	}
}