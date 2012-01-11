package org.tbyrne.display.controls
{
	import mx.states.OverrideBase;
	
	import org.tbyrne.data.controls.IControlData;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
	import org.tbyrne.display.layout.ILayoutSubject;
	
	public class TextLabelButton extends ToggleButton
	{
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
		override public function set active(value:Boolean):void{
			super.active = value;
			_textLabel.active = value;
		}
		
		protected var _textLabel:TextLabel;
		
		public function TextLabelButton(asset:IDisplayObject=null){
			super(asset);
		}
		override protected function assessData():void{
			_textLabel.data = _data;
			/*
			_textLabel.data should be set after super.data otherwise:
			_textLabel fires measurements changed
			a list might catch the event and use the old data for data>index lookup
			*/
			super.assessData();
		}
		override protected function init() : void{
			super.init();
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
		override public function setSize(width:Number, height:Number):void{
			super.setSize(width,height);
			_textLabel.setSize(width,height);
		}
		override public function setPosition(x:Number, y:Number) : void{
			super.setPosition(x,y);
			_textLabel.setPosition(x,y);
		}
		override protected function measure() : void{
			_measurements = _textLabel.measurements;
		}
		override protected function commitSize():void{
			if(_interactiveAsset!=_asset){
				_interactiveAsset.setSize(size.x,size.y);
			}
		}
		protected function onMeasurementsChange(from:ILayoutSubject, oldWidth:Number, oldHeight:Number):void{
			invalidateMeasurements();
		}
	}
}