package org.farmcode.actLibrary.application.states.states
{
	import flash.utils.Dictionary;
	
	import org.farmcode.actLibrary.application.states.AppStateMatch;
	import org.farmcode.actLibrary.application.states.reactors.PerformActReactor;
	

	public class DefaultAppState extends AbstractAppState
	{
		override public function get reactors() : Array{
			var ret:Array = super.reactors;
			if(!ret)return [defaultReactor];
			else return ret.concat(defaultReactor);
		}
		
		
		public function get lookupPattern():String{
			return _lookupPattern;
		}
		public function set lookupPattern(value:String):void{
			if(_lookupPattern!=value){
				_lookupPattern = value;
				if(_lookupPattern){
					var regStr:String = _lookupPattern.replace(AppStateConstants.REGEXP_SAFE_MATCHER,AppStateConstants.REGEXP_SAFE_REPLACE);
					regStr = regStr.replace("\*","(.*)");
					_reconstitutePattern = new RegExp(regStr);
				}else{
					_reconstitutePattern = null;
				}
			}
		}
		
		public function get displayPath():String{
			return reactorAdvice.displayPath;
		}
		public function set displayPath(value:String):void{
			reactorAdvice.displayPath = value;
		}
		
		private var _lookupPattern:String;
		private var _reconstitutePattern:RegExp;
		private var reactorAdvice:LookupFillSocketAct;
		private var defaultReactor:PerformActReactor;
		
		public function DefaultAppState(){
			defaultReactor = new PerformActReactor();
			var adviceProps:Dictionary = new Dictionary();
			adviceProps["dataPath"] = "*";
			defaultReactor.adviceProps = adviceProps;
			defaultReactor.act = reactorAdvice = new LookupFillSocketAdvice();
		}
		override public function match(path:String) : AppStateMatch{
			var ret:AppStateMatch = new AppStateMatch();
			if(_lookupPattern){
				path = _lookupPattern.replace("*",path);
			}
			ret.parameters = getBaseParams(path);
			return ret;
		}
		override public function reconstitute(match:AppStateMatch) : String{
			var ret:String = super.reconstitute(match);
			var result:Object = _reconstitutePattern.exec(ret);
			if(result.length>1){
				ret = result[1];
			}
			return ret;
		}
	}
}