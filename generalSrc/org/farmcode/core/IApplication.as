package org.farmcode.core
{
	import flash.display.DisplayObjectContainer;

	public interface IApplication
	{
		function setDisplayPosition(x:Number, y:Number, width:Number, height:Number):void;
		function set container(value:DisplayObjectContainer):void;
	}
}