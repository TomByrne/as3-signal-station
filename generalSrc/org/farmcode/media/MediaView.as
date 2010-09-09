package org.farmcode.media
{
	import flash.display.DisplayObject;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.farmcode.display.assets.assetTypes.IDisplayAsset;
	import org.farmcode.display.core.LayoutView;
	
	public class MediaView extends LayoutView
	{
		public function MediaView(asset:IDisplayAsset, measurements:Point){
			_measurements = measurements;
			super(asset);
		}
		public function displayMeasurementsChanged():void{
			performMeasChanged();
		}
		override protected function measure() : void{
			// ignore
		}
	}
}