package org.tbyrne.display.parallax.modifiers
{
	import org.tbyrne.display.parallax.IParallaxDisplay;
	
	import flash.display.DisplayObjectContainer;
	
	public interface IParallaxModifier
	{
		function modifyContainer(container:DisplayObjectContainer):void;
		function modifyItem(item:IParallaxDisplay, container:DisplayObjectContainer):void;
	}
}