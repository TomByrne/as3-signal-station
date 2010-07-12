package org.farmcode.actLibrary.external.siteStream.acts
{
	import org.farmcode.actLibrary.external.siteStream.actTypes.IReleasePathAct;
	import org.farmcode.acting.acts.UniversalAct;

	public class ReleasePathAct extends UniversalAct implements IReleasePathAct
	{
		public function get releasePath():String{
			return _releasePath;
		}
		public function set releasePath(value:String):void{
			_releasePath = value;
		}
		
		private var _releasePath:String;
		
		public function ReleasePathAct(){
			super();
		}
	}
}