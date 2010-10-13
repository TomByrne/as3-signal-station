package org.tbyrne.actLibrary.application
{

	public class StateAppConfig extends AppConfig implements IStateAppConfig
	{
		[Property(toString="true",clonable="true")]
		public function get defaultAppStatePath():String{
			return _defaultAppStatePath;
		}
		public function set defaultAppStatePath(value:String):void{
			_defaultAppStatePath = value;
		}
		[Property(toString="true",clonable="true")]
		public function get appStates():Array{
			return _appStates;
		}
		public function set appStates(value:Array):void{
			_appStates = value;
		}
		private var _defaultAppStatePath:String;
		private var _appStates:Array;
		
	}
}