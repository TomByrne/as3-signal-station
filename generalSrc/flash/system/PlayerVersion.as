package flash.system
{

	public class PlayerVersion
	{
		private static const VERSION_PARSER:RegExp = /(?P<opSys>\w+) (?P<majVer>\d+),(?P<majRev>\d+),(?P<minVer>\d+),(?P<minRev>\d+)/;
		
		private static var _instance:PlayerVersion;
		
		public static function get instance():PlayerVersion{
			if(!_instance)_instance = new PlayerVersion();
			return _instance;
		}
		
		
		public function get operatingSystem():String{
			return _operatingSystem;
		}
		
		public function get majorVersion():int{
			return _majorVersion;
		}
		public function get majorRevision():int{
			return _majorRevision;
		}
		public function get minorVersion():int{
			return _minorVersion;
		}
		public function get minorRevision():int{
			return _minorRevision;
		}
		
		private var _majorVersion:int;
		private var _majorRevision:int;
		private var _minorVersion:int;
		private var _minorRevision:int;
		private var _operatingSystem:String;
		
		public function PlayerVersion(){
			var version:String = Capabilities.version;
			var results:Object = VERSION_PARSER.exec(version);
			
			if(results){
				_operatingSystem = results.opSys;
				_majorVersion = parseInt(results.majVer);
				_majorRevision = parseInt(results.majRev);
				_minorVersion = parseInt(results.minVer);
				_minorRevision = parseInt(results.minRev);
			}else{
				Log.error( "PlayerVersion couldn't parse version string: "+version);
			}
		}
	}
}