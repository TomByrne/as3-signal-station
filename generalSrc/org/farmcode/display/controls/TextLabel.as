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
	import org.farmcode.display.assets.AssetNames;
	import org.farmcode.display.assets.assetTypes.IAsset;
	import org.farmcode.display.assets.assetTypes.IDisplayAsset;
	import org.farmcode.display.assets.assetTypes.ITextFieldAsset;
	import org.farmcode.display.utils.PaddingSizer;
	
	use namespace DisplayNamespace;
	
	public class TextLabel extends Control
	{
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
			return _labelFieldSizer.explicitPaddingTop;
		}
		public function set paddingTop(value:Number):void{
			attemptInit();
			_labelFieldSizer.explicitPaddingTop = value;
		}
		
		public function get paddingBottom():Number{
			attemptInit();
			return _labelFieldSizer.explicitPaddingBottom;
		}
		public function set paddingBottom(value:Number):void{
			_labelFieldSizer.explicitPaddingBottom = value;
		}
		
		public function get paddingLeft():Number{
			attemptInit();
			return _labelFieldSizer.explicitPaddingLeft;
		}
		public function set paddingLeft(value:Number):void{
			_labelFieldSizer.explicitPaddingLeft = value;
		}
		
		public function get paddingRight():Number{
			attemptInit();
			return _labelFieldSizer.explicitPaddingRight;
		}
		public function set paddingRight(value:Number):void{
			_labelFieldSizer.explicitPaddingRight = value;
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
		
		protected var _textFormat:TextFormat;
		protected var _assumedTextFormat:TextFormat;
		
		protected var _data:*;
		protected var _stringData:String;
		protected var _stringProvider:IStringProvider;
		protected var _valueProvider:IValueProvider;
		protected var _labelField:ITextFieldAsset;
		
		protected var _labelFieldSizer:PaddingSizer;
		
		public function TextLabel(asset:IDisplayAsset=null){
			super(asset);
		}
		override protected function init():void{
			super.init();
			_labelFieldSizer = new PaddingSizer();
			_labelFieldSizer.paddingChanged.addHandler(onPaddingChanged);
		}
		protected function onPaddingChanged(from:PaddingSizer):void{
			invalidateMeasurements();
		}
		protected function onProviderChanged(... params):void{
			if(_labelField)syncFieldToData();
		}
		override protected function bindToAsset():void{
			super.bindToAsset();
			if(asset.conformsToType(ITextFieldAsset)){
				_labelField = (asset as ITextFieldAsset);
			}
			if(!_labelField){
				_labelField = _containerAsset.takeAssetByName(AssetNames.LABEL_FIELD, ITextFieldAsset);
			}
			_assumedTextFormat = _labelField.defaultTextFormat;
			if(_backing){
				
				var operableHeight:Number = _labelField.naturalHeight-TextFieldGutter.TEXT_FIELD_GUTTER*2;
				var operableWidth:Number = _labelField.naturalWidth-TextFieldGutter.TEXT_FIELD_GUTTER*2;
				
				// some fonts have slightly different gutters, this will help us work it out.
				// This doesn't work for some dynamically created textfields (where autosizing isn't enfored at compile-time).
				/*if(operableHeight<_labelField.textHeight){
					operableHeight = _labelField.textHeight;
				}
				if(operableWidth<_labelField.textWidth){
					operableWidth = _labelField.textWidth;
				}*/
				
				_labelFieldSizer.assumedPaddingTop = (_labelField.y+TextFieldGutter.TEXT_FIELD_GUTTER)-_backing.y;
				_labelFieldSizer.assumedPaddingLeft = (_labelField.x+TextFieldGutter.TEXT_FIELD_GUTTER)-_backing.x;
				_labelFieldSizer.assumedPaddingBottom = (_backing.y+_backing.height)-(_labelField.y+TextFieldGutter.TEXT_FIELD_GUTTER+operableHeight);
				_labelFieldSizer.assumedPaddingRight = (_backing.x+_backing.width)-(_labelField.x+TextFieldGutter.TEXT_FIELD_GUTTER+operableWidth);
			}
			if(_data)syncFieldToData();
			else if(_labelField.text.length)_data = _labelField.text;
			applyFormat();
		}
		override protected function unbindFromAsset():void{
			_labelFieldSizer.assumedPaddingTop = NaN;
			_labelFieldSizer.assumedPaddingLeft = NaN;
			_labelFieldSizer.assumedPaddingBottom = NaN;
			_labelFieldSizer.assumedPaddingRight = NaN;
			
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
				
				var measWidth:Boolean = useMeasuredWidth();
				
				var textWas:String = _labelField.htmlText;
				var measText:String = getMeasurementText();
				var widthWas:Number = _labelField.width;
				if(measWidth){
					if(_backing)_labelField.width = _backing.naturalWidth-_labelFieldSizer.paddingLeft-_labelFieldSizer.paddingRight+TextFieldGutter.TEXT_FIELD_GUTTER*2;
					else _labelField.width = _labelField.naturalWidth;
					
					_measurements.x = _labelField.textWidth+_labelFieldSizer.paddingLeft+_labelFieldSizer.paddingRight;
				}else{
					_measurements.x = _labelField.naturalWidth+_labelFieldSizer.paddingLeft+_labelFieldSizer.paddingRight;
					_labelField.width = _labelField.naturalWidth;
				}
				_measurements.y = _labelField.textHeight+_labelFieldSizer.paddingTop+_labelFieldSizer.paddingBottom;
				
				_labelField.width = widthWas;
				if(measText!=textWas)_labelField.htmlText = textWas;
			}else{
				invalidateMeasurements();
			}
		}
		protected function useMeasuredWidth():Boolean{
			return (!_labelField.multiline);
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
			invalidateMeasurements();
		}
		override protected function validateSize():void{
			super.validateSize();
			
			var labelWidth:Number = size.x-_labelFieldSizer.paddingLeft-_labelFieldSizer.paddingRight+TextFieldGutter.TEXT_FIELD_GUTTER*2;
			var labelHeight:Number = size.y-_labelFieldSizer.paddingTop-_labelFieldSizer.paddingBottom+TextFieldGutter.TEXT_FIELD_GUTTER*2;
			if(labelWidth!=_labelField.width){
				var textHeightWas:Number = _labelField.textHeight;
				_labelField.setSize(labelWidth,labelHeight);
				if(_labelField.textHeight!=textHeightWas){
					invalidateMeasurements();
				}
			}else{
				_labelField.height = labelHeight;
			}
			if(_labelField!=asset){
				_labelField.setPosition(-TextFieldGutter.TEXT_FIELD_GUTTER+_labelFieldSizer.paddingLeft,-TextFieldGutter.TEXT_FIELD_GUTTER+_labelFieldSizer.paddingTop);
			}
		}
		override protected function validatePosition():void{
			if(_labelField==asset){
				asset.setPosition(position.x-TextFieldGutter.TEXT_FIELD_GUTTER+_labelFieldSizer.paddingLeft,position.y-TextFieldGutter.TEXT_FIELD_GUTTER+_labelFieldSizer.paddingTop);
			}else{
				super.validatePosition();
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