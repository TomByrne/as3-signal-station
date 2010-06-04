package org.farmcode.display.assets
{
	import flash.display.Graphics;

	public interface IShapeAsset extends IDisplayAsset
	{
		function get graphics():IGraphicsAsset;
	}
}