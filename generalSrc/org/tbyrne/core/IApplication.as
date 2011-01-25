package org.tbyrne.core
{
	import org.tbyrne.display.assets.nativeTypes.IDisplayObjectContainer;

	public interface IApplication
	{
		function setPosition(x:Number, y:Number):void;
		function setSize(width:Number, height:Number):void;
		function set container(value:IDisplayObjectContainer):void;
	}
}