package org.farmcode.media
{
	import flash.display.DisplayObject;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.farmcode.display.assets.IDisplayAsset;
	import org.farmcode.display.core.LayoutView;
	
	public class MediaView extends LayoutView
	{
		public function MediaView(asset:IDisplayAsset, measurements:Point){
			_measurements = measurements;
			super(asset);
		}
		public function displayMeasurementsChanged():void{
			dispatchMeasurementChange();
		}
		override protected function measure() : void{
			// ignore
		}
		override protected function draw() : void{
			positionAsset();
			asset.width = displayPosition.width;
			asset.height = displayPosition.height;
		}
	}
}