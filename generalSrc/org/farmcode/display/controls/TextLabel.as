package org.farmcode.display.controls
{
	import flash.display.DisplayObject;
	import flash.display.TextFieldGutter;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import org.farmcode.data.dataTypes.IStringProvider;
	import org.farmcode.data.dataTypes.IValueProvider;
	import org.farmcode.display.DisplayNamespace;
	import org.farmcode.display.assets.IAsset;
	import org.farmcode.display.assets.IDisplayAsset;
	import org.farmcode.display.assets.ITextFieldAsset;
	
	use namespace DisplayNamespace;
	
	public class TextLabel extends Control
	{
		DisplayNamespace static const LABEL_FIELD_CHILD:String = "labelField";
		
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
					syncFieldToData();
				}
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
		public function get textFormat():TextFormat{
			return _textFormat;
		}
		public function set textFormat(value:TextFormat):void{
			if(_textFormat!=value){
				_textFormat = value;
				applyFormat();
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
		
		protected var _textFormat:TextFormat;
		protected var _assumedTextFormat:TextFormat;
		
		protected var _data:*;
		protected var _stringData:String;
		protected var _stringProvider:IStringProvider;
		protected var _valueProvider:IValueProvider;
		protected var _labelField:ITextFieldAsset;
		
		public function TextLabel(asset:IDisplayAsset=null){
			super(asset);
		}
		protected function onProviderChanged(... params):void{
			if(_labelField)syncFieldToData();
		}
		override protected function bindToAsset():void{
			super.bindToAsset();
			_labelField = (asset as ITextFieldAsset);
			if(!_labelField){
				_labelField = _containerAsset.takeAssetByName(LABEL_FIELD_CHILD, ITextFieldAsset);
			}
			_assumedTextFormat = _labelField.defaultTextFormat;
			if(_backing){
				// some fonts have slightly different gutters, this will help us work it out.
				
				var operableHeight:Number;
				if(_labelField.height<_labelField.textHeight+TextFieldGutter.TEXT_FIELD_GUTTER*2){
					operableHeight = _labelField.textHeight;
				}else{
					operableHeight = _labelField.height-TextFieldGutter.TEXT_FIELD_GUTTER*2;
				}
				
				var operableWidth:Number;
				if(_labelField.width<_labelField.textWidth+TextFieldGutter.TEXT_FIELD_GUTTER*2){
					operableWidth = _labelField.textWidth;
				}else{
					operableWidth = _labelField.width-TextFieldGutter.TEXT_FIELD_GUTTER*2;
				}
				
				_assumedPaddingTop = (_labelField.y+TextFieldGutter.TEXT_FIELD_GUTTER)-_backing.y;
				_assumedPaddingLeft = (_labelField.x+TextFieldGutter.TEXT_FIELD_GUTTER)-_backing.x;
				_assumedPaddingBottom = (_backing.y+_backing.height)-(_labelField.y+TextFieldGutter.TEXT_FIELD_GUTTER+operableHeight);
				_assumedPaddingRight = (_backing.x+_backing.width)-(_labelField.x+TextFieldGutter.TEXT_FIELD_GUTTER+operableWidth);
			}else{
				_assumedPaddingTop = 0;
				_assumedPaddingLeft = 0;
				_assumedPaddingBottom = 0;
				_assumedPaddingRight = 0;
			}
			if(_data && _labelField)syncFieldToData();
			applyFormat();
		}
		override protected function unbindFromAsset():void{
			if(_assumedTextFormat){
				_labelField.defaultTextFormat = _assumedTextFormat;
				_labelField.setTextFormat(_assumedTextFormat);
				_assumedTextFormat = null;
			}
			_stringData = null;
			if(_labelField!=asset){
				_containerAsset.returnAsset(_labelField);
				_labelField = null;
			}
			super.unbindFromAsset();
		}
		override protected function measure():void{
			checkIsBound();
			if(asset){
				var paddingTop:Number = (isNaN(_paddingTop)?_assumedPaddingTop:_paddingTop);
				var paddingBottom:Number = (isNaN(_paddingBottom)?_assumedPaddingBottom:_paddingBottom);
				var paddingLeft:Number = (isNaN(_paddingLeft)?_assumedPaddingLeft:_paddingLeft);
				var paddingRight:Number = (isNaN(_paddingRight)?_assumedPaddingRight:_paddingRight);
				
				var textWas:String = _labelField.htmlText;
				var widthWas:Number = _labelField.width;
				var measText:String = getMeasurementText();
				
				if(_backing)_labelField.width = _backing.naturalWidth-paddingLeft-paddingRight+TextFieldGutter.TEXT_FIELD_GUTTER*2;
				else _labelField.width = _labelField.naturalWidth;
				
				if(measText!=textWas)_labelField.htmlText = measText;
				
				_measurements.x = _labelField.textWidth+paddingLeft+paddingRight;
				_measurements.y = _labelField.textHeight+paddingTop+paddingBottom;
				_labelField.width = widthWas;
				
				if(measText!=textWas)_labelField.htmlText = textWas;
			}else{
				_measureFlag.invalidate();
			}
		}
		protected function getMeasurementText():String{
			return _labelField.htmlText;
		}
		protected function applyFormat() : void{
			if(_labelField){
				var format:TextFormat = getValueOrAssumed(_textFormat,_assumedTextFormat);
				if(format){
					_labelField.defaultTextFormat = format;
					_labelField.setTextFormat(format);
				}
			}
		}
		protected function syncFieldToData():void{
			var newText:String;
			if(_stringProvider){
				newText = _stringProvider.stringValue?_stringProvider.stringValue:"";
			}else if(_valueProvider){
				newText = _valueProvider.value?String(_valueProvider.value):"";
			}else if(_data is String){
				newText = _data;
			}else if(_data is Object && _data["label"]){
				newText = _data["label"];
			}
			if(!newText)newText = "";
			if(_stringData != newText){
				_stringData = newText;
				fillField();
			}
		}
		protected function fillField():void{
			_labelField.htmlText = _stringData;
			dispatchMeasurementChange();
		}
		override protected function draw():void{
			super.draw();
			
			var paddingTop:Number = getValueOrAssumed(_paddingTop,_assumedPaddingTop,0);
			var paddingLeft:Number = getValueOrAssumed(_paddingLeft,_assumedPaddingLeft,0);
			var paddingBottom:Number = getValueOrAssumed(_paddingBottom,_assumedPaddingBottom,0);
			var paddingRight:Number = getValueOrAssumed(_paddingRight,_assumedPaddingRight,0);
			
			positionAsset();
			
			var labelWidth:Number = displayPosition.width-paddingLeft-paddingRight+TextFieldGutter.TEXT_FIELD_GUTTER*2;
			if(labelWidth!=_labelField.width){
				var textHeightWas:Number = _labelField.textHeight;
				_labelField.width = labelWidth;
				if(_labelField.textHeight!=textHeightWas){
					dispatchMeasurementChange();
				}
			}
			_labelField.height = displayPosition.height-paddingTop-paddingBottom+TextFieldGutter.TEXT_FIELD_GUTTER*2;
		}
		override protected function positionAsset():void{
			var paddingTop:Number = getValueOrAssumed(_paddingTop,_assumedPaddingTop,0);
			var paddingLeft:Number = getValueOrAssumed(_paddingLeft,_assumedPaddingLeft,0);
			var paddingBottom:Number = getValueOrAssumed(_paddingBottom,_assumedPaddingBottom,0);
			var paddingRight:Number = getValueOrAssumed(_paddingRight,_assumedPaddingRight,0);
			
			if(_labelField==asset){
				asset.x = displayPosition.x-TextFieldGutter.TEXT_FIELD_GUTTER+paddingLeft;
				asset.y = displayPosition.y-TextFieldGutter.TEXT_FIELD_GUTTER+paddingTop;
			}else{
				super.positionAsset();
				_labelField.x = -TextFieldGutter.TEXT_FIELD_GUTTER+paddingLeft;
				_labelField.y = -TextFieldGutter.TEXT_FIELD_GUTTER+paddingTop;
			}
		}
		protected function getValueOrAssumed(value:*, assumedValue:*, defaultValue:*=null) : *{
			if(value!=null && (!isNaN(value) || !(value is Number))){
				return value;
			}else if(assumedValue!=null && (!isNaN(assumedValue) || !(assumedValue is Number))){
				return assumedValue;
			}
			return defaultValue;
		}
	}
}