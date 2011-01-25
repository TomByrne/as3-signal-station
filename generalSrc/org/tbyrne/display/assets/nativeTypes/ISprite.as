package org.tbyrne.display.assets.nativeTypes
{

	public interface ISprite extends IDisplayObjectContainer
	{
		function get useHandCursor():Boolean;
		function set useHandCursor(value:Boolean):void;
		
		function get buttonMode():Boolean;
		function set buttonMode(value:Boolean):void;
		
		function get hitArea():ISprite;
		function set hitArea(value:ISprite):void;
	}
}