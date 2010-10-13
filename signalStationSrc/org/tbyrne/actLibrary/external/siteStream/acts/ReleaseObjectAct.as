package org.tbyrne.actLibrary.external.siteStream.acts
{
	import org.tbyrne.actLibrary.external.siteStream.actTypes.IReleaseObjectAct;
	import org.tbyrne.acting.acts.UniversalAct;

	public class ReleaseObjectAct extends UniversalAct implements IReleaseObjectAct
	{
		public function get releaseObject():Object{
			return _releaseObject;
		}
		public function set releaseObject(value:Object):void{
			_releaseObject = value;
		}
		
		private var _releaseObject:Object;
		
		public function ReleaseObjectAct(){
			super();
		}
	}
}