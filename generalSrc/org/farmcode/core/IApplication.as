package org.farmcode.core
{
	import org.farmcode.display.assets.assetTypes.IContainerAsset;

	public interface IApplication
	{
		function setPosition(x:Number, y:Number):void;
		function setSize(width:Number, height:Number):void;
		function set container(value:IContainerAsset):void;
	}
}