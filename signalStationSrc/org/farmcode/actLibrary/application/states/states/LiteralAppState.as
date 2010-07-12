package org.farmcode.actLibrary.application.states.states
{
	import org.farmcode.actLibrary.application.states.AppStateMatch;

	public class LiteralAppState extends AbstractAppState
	{
		public var path:String;
		
		public function LiteralAppState(path:String=null){
			super();
			this.path = path;
		}
		override public function match(path:String):AppStateMatch{
			if(this.path==path){
				var ret:AppStateMatch = new AppStateMatch();
				ret.parameters = getBaseParams(path);
				return ret;
			}
			return null;
		}
	}
}