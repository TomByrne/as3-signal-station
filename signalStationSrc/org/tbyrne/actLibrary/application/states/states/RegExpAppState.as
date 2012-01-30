package org.tbyrne.actLibrary.application.states.states
{
	import flash.utils.Dictionary;
	
	import org.tbyrne.actLibrary.application.states.AppStateMatch;
	import org.tbyrne.actLibrary.application.states.serialisers.IPropSerialiser;
	import org.tbyrne.reflection.Deliterator;

	public class RegExpAppState extends AbstractAppState
	{
		public static const STAR_PSUEDONYM:String = "__all";
		
		public function get path():String{
			return _path;
		}
		public function set path(value:String):void{
			if(_path!=value){
				_path = value;
				_invalidStrip = true;
			}
		}
		public function get serialisers():Object{
			return _serialisers;
		}
		public function set serialisers(value:Object):void{
			if(_serialisers!=value){
				_serialisers = value;
			}
		}
		
		protected var _serialisers:Object;
		
		private var _path:String;
		
		private var _invalidStrip:Boolean;
		private var _stripPattern:String;
		private var _stripRegExp:RegExp;
		
		public function RegExpAppState(stateId:String=null, statePath:String=null){
			super(stateId);
			path = statePath;
		}
		override public function match(path:String) : AppStateMatch{
			if(_path){
				validateStrip();
				var result:Object = _stripRegExp.exec(path);
				var test:Boolean = _stripRegExp.test(path);
				if(result){
					var serialiser:IPropSerialiser;
					var ret:AppStateMatch = new AppStateMatch();
					var params:Dictionary = getBaseParams(path);
					for(var prop:String in result){
						var destProp:String = (prop==STAR_PSUEDONYM?"*":prop);
						var value:* = result[prop];
						if(_serialisers && (serialiser=_serialisers[destProp])){
							value = serialiser.deserialise(value);
						}else{
							value = Deliterator.deliterate(value);
						}
						params[destProp] = value;
					}
					ret.parameters = params;
					return ret;
				}
			}
			return null;
		}
		protected function validateStrip():void{
			if(_invalidStrip){
				_invalidStrip = false;
				_stripPattern = getStripPattern(_path);
				_stripRegExp = new RegExp(_stripPattern);
			}
		}
		override public function reconstitute(match:AppStateMatch):String{
			return match.parameters["*"];
		}
		protected function getStripPattern(path:String) : String{
			return path;
		}
	}
}