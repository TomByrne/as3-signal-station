package org.farmcode.display.behaviour.controls
{
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	
	import org.farmcode.data.dataTypes.IStringProvider;
	import org.farmcode.data.dataTypes.IValueProvider;
	
	//TODO: combine duplicated functionality from TextInput
	public class TextLabel extends Control
	{
		private static const TEXT_FIELD_GUTTER:Number = 2;
		
		public function get data():*{
			return _data;
		}
		public function set data(value:*):void{
			if(_data!=value){
				if(_stringProvider){
					_stringProvider.stringValueChanged.removeHandler(onProviderChanged);
				}else if(_valueProvider){
					_valueProvider.valueChanged.removeHandler(onProviderChanged);
				}
				_data = value;
				_stringProvider = value as IStringProvider;
				if(_stringProvider){
					_stringProvider.stringValueChanged.addHandler(onProviderChanged);
				}else{
					_valueProvider = value as IValueProvider;
					if(_valueProvider){
						_valueProvider.valueChanged.addHandler(onProviderChanged);
					}
				}
				if(_labelField){
					commitText();
				}
				dispatchMeasurementChange();
			}
		}
		
		public function get paddingTop():Number{
			return _paddingTop;
		}
		public function set paddingTop(value:Number):void{
			if(_paddingTop!=value){
				_paddingTop = value;
				dispatchMeasurementChange()
			}
		}
		
		public function get paddingBottom():Number{
			return _paddingBottom;
		}
		public function set paddingBottom(value:Number):void{
			if(_paddingBottom!=value){
				_paddingBottom = value;
				dispatchMeasurementChange()
			}
		}
		
		public function get paddingLeft():Number{
			return _paddingLeft;
		}
		public function set paddingLeft(value:Number):void{
			if(_paddingLeft!=value){
				_paddingLeft = value;
				dispatchMeasurementChange()
			}
		}
		
		public function get paddingRight():Number{
			return _paddingRight;
		}
		public function set paddingRight(value:Number):void{
			if(_paddingRight!=value){
				_paddingRight = value;
				dispatchMeasurementChange()
			}
		}
		
		private var _paddingRight:Number;
		private var _paddingLeft:Number;
		private var _paddingBottom:Number;
		private var _paddingTop:Number;
		
		private var _assumedPaddingRight:Number;
		private var _assumedPaddingLeft:Number;
		private var _assumedPaddingBottom:Number;
		private var _assumedPaddingTop:Number;
		
		private var _data:*;
		private var _stringProvider:IStringProvider;
		private var _valueProvider:IValueProvider;
		private var _labelField:TextField;
		private var _labelBacking:DisplayObject;
		
		public function TextLabel(asset:DisplayObject=null){
			super(asset);
		}
		protected function onProviderChanged(... params):void{
			if(_labelField)commitText();
		}
		protected function commitText():void{
			if(_stringProvider){
				_labelField.htmlText = _stringProvider.stringValue?_stringProvider.stringValue:"";
			}else if(_valueProvider){
				_labelField.htmlText = _valueProvider.value?String(_valueProvider.value):"";
			}else if(_data is String){
				_labelField.htmlText = _data;
			}else if(_data is Object && _data["label"]){
				_labelField.htmlText = _data["label"];
			}
		}
		override protected function bindToAsset():void
		{
			_labelField = containerAsset.getChildByName("labelField") as TextField;
			if(_data && _labelField)commitText();
			_labelBacking = containerAsset.getChildByName("labelBacking")
			if(_labelBacking){
				_assumedPaddingTop = (_labelField.y+TEXT_FIELD_GUTTER)-_labelBacking.y;
				_assumedPaddingLeft = (_labelField.x+TEXT_FIELD_GUTTER)-_labelBacking.x;
				_assumedPaddingBottom = (_labelBacking.y+_labelBacking.height)-(_labelField.y+_labelField.height-TEXT_FIELD_GUTTER);
				_assumedPaddingRight = (_labelBacking.x+_labelBacking.width)-(_labelField.x+_labelField.width-TEXT_FIELD_GUTTER);
			}else{
				_assumedPaddingTop = 0;
				_assumedPaddingLeft = 0;
				_assumedPaddingBottom = 0;
				_assumedPaddingRight = 0;
			}
		}
		override protected function unbindFromAsset():void
		{
			_labelField = null;
		}
		override protected function measure():void{
			if(asset){
				var paddingTop:Number = (isNaN(_paddingTop)?_assumedPaddingTop:_paddingTop);
				var paddingBottom:Number = (isNaN(_paddingBottom)?_assumedPaddingBottom:_paddingBottom);
				var paddingLeft:Number = (isNaN(_paddingLeft)?_assumedPaddingLeft:_paddingLeft);
				var paddingRight:Number = (isNaN(_paddingRight)?_assumedPaddingRight:_paddingRight);
				
				if(!_displayMeasurements)_displayMeasurements = new Rectangle();
				_displayMeasurements.width = _labelField.textWidth+paddingLeft+paddingRight;
				_displayMeasurements.height = _labelField.textHeight+paddingTop+paddingBottom;
			}else{
				_measureFlag.invalidate();
			}
		}
		override protected function draw():void
		{
			var paddingTop:Number = (isNaN(_paddingTop)?_assumedPaddingTop:_paddingTop);
			var paddingBottom:Number = (isNaN(_paddingBottom)?_assumedPaddingBottom:_paddingBottom);
			var paddingLeft:Number = (isNaN(_paddingLeft)?_assumedPaddingLeft:_paddingLeft);
			var paddingRight:Number = (isNaN(_paddingRight)?_assumedPaddingRight:_paddingRight);
			
			asset.x = displayPosition.x;
			asset.y = displayPosition.y;
			_labelField.x = -TEXT_FIELD_GUTTER+paddingLeft;
			_labelField.y = -TEXT_FIELD_GUTTER+paddingTop;
			_labelField.width = displayPosition.width-paddingLeft-paddingRight+TEXT_FIELD_GUTTER*2;
			_labelField.height = displayPosition.height-paddingTop-paddingBottom+TEXT_FIELD_GUTTER*2;
			if(_labelBacking){
				_labelBacking.width = displayPosition.width;
				_labelBacking.height = displayPosition.height;
			}
		}
	}
}