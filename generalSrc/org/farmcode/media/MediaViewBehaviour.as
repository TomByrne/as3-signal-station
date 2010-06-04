package org.farmcode.media
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import org.farmcode.display.behaviour.LayoutViewBehaviour;
	
	public class MediaViewBehaviour extends LayoutViewBehaviour
	{
		public function MediaViewBehaviour(asset:DisplayObject, displayMeasurements:Rectangle){
			super(asset);
			_displayMeasurements = displayMeasurements;
		}
		public function displayMeasurementsChanged():void{
			dispatchMeasurementChange();
		}
		override protected function measure() : void{
			// ignore
		}
		override protected function draw() : void{
			asset.x = displayPosition.x;
			asset.y = displayPosition.y;
			asset.width = displayPosition.width;
			asset.height = displayPosition.height;
		}
	}
}