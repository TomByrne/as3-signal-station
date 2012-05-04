package org.tbyrne.display.assets.nativeTypes
{
	public interface IMovieClip extends ISprite
	{
		function get totalFrames():int;
		function get currentFrame():int;
		function play():void;
		function stop():void;
		function gotoAndPlay(frame:Object, scene:String=null):void;
		function gotoAndStop(frame:Object, scene:String=null):void;
	}
}