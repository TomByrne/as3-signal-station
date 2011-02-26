package org.tbyrne.debug.logging
{
	public class AbstractLogger
	{
		private var LEVEL_NAMES:Array;
		private var LEVEL_COLOURS:Array;
		
		public function AbstractLogger()
		{
		}
		protected function getLevelName(level:int):String{
			if(!LEVEL_NAMES){
				LEVEL_NAMES = [];
				LEVEL_NAMES[Log.USER_INFO] = 					"USER INFO: ";
				LEVEL_NAMES[Log.USER_ERROR] = 					"USER ERROR: ";
				LEVEL_NAMES[Log.DEV_INFO] = 					"INFO: ";
				LEVEL_NAMES[Log.PERFORMANCE] = 					"PERFORMANCE: ";
				LEVEL_NAMES[Log.SUSPICIOUS_IMPLEMENTATION] = 	"SUSPICIOUS: ";
				LEVEL_NAMES[Log.ERROR] = 						"ERROR: ";
			}
			return LEVEL_NAMES[level];
		}
		
		protected function getLevelColour(level:int):Number{
			if(!LEVEL_COLOURS){
				LEVEL_COLOURS = [];
				LEVEL_COLOURS[Log.USER_INFO] = 					0x000000;
				LEVEL_COLOURS[Log.USER_ERROR] = 				0xff0000;
				LEVEL_COLOURS[Log.DEV_INFO] = 					0x000000;
				LEVEL_COLOURS[Log.PERFORMANCE] = 				0x000000;
				LEVEL_COLOURS[Log.SUSPICIOUS_IMPLEMENTATION] = 	0x0000ff;
				LEVEL_COLOURS[Log.ERROR] = 						0xff0000;
			}
			return LEVEL_COLOURS[level];
		}
	}
}