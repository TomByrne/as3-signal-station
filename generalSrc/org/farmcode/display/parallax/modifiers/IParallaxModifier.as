package org.farmcode.display.parallax.modifiers
{
	import org.farmcode.display.parallax.IParallaxDisplay;
	
	import flash.display.DisplayObjectContainer;
	
	public interface IParallaxModifier
	{
		function modifyContainer(container:DisplayObjectContainer):void;
		function modifyItem(item:IParallaxDisplay, container:DisplayObjectContainer):void;
	}
}