package org.farmcode.display.controls
{
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	
	import org.farmcode.display.assets.assetTypes.IAsset;
	import org.farmcode.display.assets.assetTypes.IDisplayAsset;
	import org.farmcode.display.layout.ILayoutSubject;
	
	public class TextLabelButton extends ToggleButton
	{
		override public function set data(value:*):void{
			super.data = value;
			_textLabel.data = value;
		}
		public function get paddingTop():Number{
			return _textLabel.paddingTop;
		}
		public function set paddingTop(value:Number):void{
			_textLabel.paddingTop = value;
		}
		
		public function get paddingBottom():Number{
			return _textLabel.paddingBottom;
		}
		public function set paddingBottom(value:Number):void{
			_textLabel.paddingBottom = value;
		}
		
		public function get paddingLeft():Number{
			return _textLabel.paddingLeft;
		}
		public function set paddingLeft(value:Number):void{
			_textLabel.paddingLeft = value;
		}
		
		public function get paddingRight():Number{
			return _textLabel.paddingRight;
		}
		public function set paddingRight(value:Number):void{
			_textLabel.paddingRight = value;
		}
		public function set padding(value:Number):void{
			paddingTop = value;
			paddingBottom = value;
			paddingLeft = value;
			paddingRight = value;
		}
		
		protected var _textLabel:TextLabel;
		
		public function TextLabelButton(asset:IDisplayAsset=null){
			super(asset);
			togglable = false;
			createTextLabel();
			_textLabel.measurementsChanged.addHandler(onMeasurementsChange);
		}
		protected function createTextLabel() : void{
			_textLabel = new TextLabel();
		}
		override protected function bindToAsset() : void{
			super.bindToAsset();
			_textLabel.asset = asset;
		}
		override protected function unbindFromAsset() : void{
			super.unbindFromAsset();
			_textLabel.asset = null;
		}
		override public function setDisplayPosition(x:Number, y:Number, width:Number, height:Number) : void{
			super.setDisplayPosition(x,y,width,height);
			_textLabel.setDisplayPosition(x,y,width,height);
			_interactiveArea.setSize(width,height);
		}
		override protected function measure() : void{
			_measurements = _textLabel.measurements;
		}
		protected function onMeasurementsChange(from:ILayoutSubject, oldWidth:Number, oldHeight:Number):void{
			performMeasChanged();
		}
	}
}