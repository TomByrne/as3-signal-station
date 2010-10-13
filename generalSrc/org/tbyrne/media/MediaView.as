package org.tbyrne.media
{
	import flash.display.DisplayObject;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.tbyrne.display.assets.assetTypes.IDisplayAsset;
	import org.tbyrne.display.core.LayoutView;
	
	public class MediaView extends LayoutView
	{
		public function MediaView(asset:IDisplayAsset, measurements:Point){
			_measurements = measurements;
			super(asset);
		}
		public function displayMeasurementsChanged():void{
			invalidateMeasurements();
		}
		override protected function measure() : void{
			// ignore
		}
	}
}