package au.com.thefarmdigital.parallax.modifiers
{
	import au.com.thefarmdigital.parallax.IParallaxDisplay;
	
	import flash.display.DisplayObjectContainer;
	
	public interface IParallaxModifier
	{
		function modifyContainer(container:DisplayObjectContainer):void;
		function modifyItem(item:IParallaxDisplay, container:DisplayObjectContainer):void;
	}
}