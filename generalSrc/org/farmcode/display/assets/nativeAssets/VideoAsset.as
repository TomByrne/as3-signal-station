package org.farmcode.display.assets.nativeAssets
{
	import flash.display.DisplayObject;
	import flash.media.Video;
	
	import org.farmcode.display.assets.IVideoAsset;
	
	public class VideoAsset extends DisplayObjectAsset implements IVideoAsset
	{
		public function get video():Video {
			return _video;
		}
		override public function set displayObject(value:DisplayObject):void {
			super.displayObject = value;
			_video = (value as Video);
		}
		
		private var _video:Video;
		
		
		public function VideoAsset()
		{
			super();
		}
	}
}