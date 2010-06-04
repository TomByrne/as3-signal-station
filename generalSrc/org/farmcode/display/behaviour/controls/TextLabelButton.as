package org.farmcode.display.behaviour.controls
{
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	
	import org.farmcode.display.layout.ILayoutSubject;
	
	public class TextLabelButton extends ToggleButton
	{
		override public function get displayMeasurements() : Rectangle{
			checkIsBound()
			return textLabel.displayMeasurements;
		}
		
		override public function set data(value:*):void{
			super.data = value;
			textLabel.data = value;
		}
		
		private var textLabel:TextLabel = new TextLabel();
		
		public function TextLabelButton(asset:DisplayObject=null){
			super(asset);
			textLabel.measurementsChanged.addHandler(onMeasurementsChange);
		}
		override protected function bindToAsset() : void{
			super.bindToAsset();
			textLabel.setAssetAndPosition(asset);
		}
		override protected function unbindFromAsset() : void{
			super.unbindFromAsset();
			textLabel.asset = null;
		}
		override public function setDisplayPosition(x:Number, y:Number, width:Number, height:Number) : void{
			super.setDisplayPosition(x,y,width,height);
			textLabel.setDisplayPosition(x,y,width,height);
		}
		override protected function measure() : void{
			// ignore
		}
		protected function onMeasurementsChange(from:ILayoutSubject, oldX:Number, oldY:Number, oldWidth:Number, oldHeight:Number):void{
			dispatchMeasurementChange();
		}
	}
}