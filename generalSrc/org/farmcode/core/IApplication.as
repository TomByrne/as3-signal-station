package org.farmcode.core
{
	import org.farmcode.display.assets.assetTypes.IContainerAsset;

	public interface IApplication
	{
		function setDisplayPosition(x:Number, y:Number, width:Number, height:Number):void;
		function set container(value:IContainerAsset):void;
	}
}