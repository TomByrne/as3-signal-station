package flash.display
{
	import flash.geom.Point;
	import flash.system.Capabilities;
	import flash.system.PlayerTypes;
	import flash.system.PlayerVersion;

	public class BitmapSizeValid
	{
		
		private static const OLD_MAX_WIDTH:Number = 2880;
		private static const OLD_MAX_HEIGHT:Number = 2880;
		
		private static const NEW_MAX_WIDTH:Number = 8191;
		private static const NEW_MAX_HEIGHT:Number = 8191;
		
		private static const NEW_MAX_PIXELS:Number = 16777215;
		
		private static var isNewVersion:Boolean;
		{
			switch (Capabilities.playerType) {
				case PlayerTypes.DESKTOP:
					isNewVersion = (PlayerVersion.instance.majorVersion>=1 && PlayerVersion.instance.majorRevision>=5);
					break;
				default:
					isNewVersion = (PlayerVersion.instance.majorVersion>=10);
					
			}
		}
		
		public static function isValidSize(width:Number, height:Number):Boolean{
			if(isNewVersion){
				if(width<=NEW_MAX_WIDTH && height<=NEW_MAX_HEIGHT){
					return (width*height<NEW_MAX_PIXELS);
				}else{
					return false;
				}
			}else{
				return (width<=OLD_MAX_WIDTH && height<=OLD_MAX_HEIGHT);
			}
		}
		public static function getMaxDimsForWidth(width:Number, fillPoint:Point=null):Point{
			if(!fillPoint)fillPoint = new Point();
			if(isNewVersion){
				fillPoint.x = (width<=NEW_MAX_WIDTH?width:NEW_MAX_WIDTH);
				var newHeight:int = int(NEW_MAX_PIXELS/fillPoint.x);
				fillPoint.y = (newHeight<=NEW_MAX_HEIGHT?newHeight:NEW_MAX_HEIGHT);
			}else{
				fillPoint.x = (width<=OLD_MAX_WIDTH?width:OLD_MAX_WIDTH);
				fillPoint.y = OLD_MAX_HEIGHT;
			}
			return fillPoint;
		}
		public static function getMaxDimsForHeight(height:Number, fillPoint:Point=null):Point{
			if(!fillPoint)fillPoint = new Point();
			if(isNewVersion){
				fillPoint.y = (height<=NEW_MAX_HEIGHT?height:NEW_MAX_HEIGHT);
				var newWidth:int = int(NEW_MAX_PIXELS/fillPoint.y);
				fillPoint.x = (newWidth<=NEW_MAX_WIDTH?newWidth:NEW_MAX_WIDTH);
			}else{
				fillPoint.y = (height<=OLD_MAX_HEIGHT?height:OLD_MAX_HEIGHT);
				fillPoint.x = OLD_MAX_WIDTH;
			}
			return fillPoint;
		}
	}
}