package org.tbyrne.display.controls
{
	import flash.display.TextFieldGutter;
	import flash.text.TextFormat;
	
	import org.tbyrne.data.core.StringData;
	import org.tbyrne.data.dataTypes.IStringProvider;
	import org.tbyrne.data.dataTypes.IValueProvider;
	import org.tbyrne.display.DisplayNamespace;
	import org.tbyrne.display.assets.AssetNames;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
	import org.tbyrne.display.assets.nativeTypes.ITextField;
	import org.tbyrne.display.utils.PaddingSizer;
	
	use namespace DisplayNamespace;
	
	public class TextLabel extends Control
	{
		public function get stringData():String{
			checkIsBound();
			return _stringData;
		}
		public function get data():*{
			checkIsBound();
			return _data;
		}
		public function set data(value:*):void{
			if(_data!=value){
				if(_stringProvider){
					_stringProvider.stringValueChanged.removeHandler(onProviderChanged);
				}else if(_valueProvider){
					_valueProvider.valueChanged.removeHandler(onProviderChanged);
				}
				if(value is String){
					value = new StringData(value);
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
			attemptInit();
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
			attemptInit();
			_labelFieldSizer.explicitPaddingBottom = value;
		}
		
		public function get paddingLeft():Number{
			attemptInit();
			return _labelFieldSizer.explicitPaddingLeft;
		}
		public function set paddingLeft(value:Number):void{
			attemptInit();
			_labelFieldSizer.explicitPaddingLeft = value;
		}
		
		public function get paddingRight():Number{
			attemptInit();
			return _labelFieldSizer.explicitPaddingRight;
		}
		public function set paddingRight(value:Number):void{
			attemptInit();
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
		
		public function get multiline():Boolean{
			return _multiline;
		}
		public function set multiline(value:Boolean):void{
			if(_multiline!=value){
				_multiline = value;
				_multilineSet = true;
				if(_labelField){
					_labelField.multiline = _multiline;
					_labelField.wordWrap = _multiline;
				}
				invalidateMeasurements();
			}
		}
		
		private var _multiline:Boolean;
		private var _multilineSet:Boolean;
		private var _assumedMultiline:Boolean;
		
		protected var _textFormat:TextFormat;
		protected var _assumedTextFormat:TextFormat;
		
		protected var _data:*;
		protected var _stringData:String;
		protected var _stringProvider:IStringProvider;
		protected var _valueProvider:IValueProvider;
		protected var _labelField:ITextField;
		
		protected var _labelFieldSizer:PaddingSizer;
		
		public function TextLabel(asset:IDisplayObject=null){
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
			bindTextField();
			_assumedMultiline = _labelField.multiline;
			if(_multilineSet){
				_labelField.multiline = _multiline;
				_labelField.wordWrap = _multiline;
			}
			if(!_data && _labelField.text.length){
				_data = _labelField.htmlText;
				_stringData = _data;
			}
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
			syncFieldToData();
			applyFormat();
		}
		public function unsetMultiline():void{
			_multilineSet = false;
			if(isBound){
				_labelField.multiline = _assumedMultiline;
				_labelField.wordWrap = _assumedMultiline;
			}
		}
		protected function bindTextField():void{
			if(asset.conformsToType(ITextField)){
				_labelField = (asset as ITextField);
			}
			if(!_labelField){
				_labelField = _containerAsset.takeAssetByName(AssetNames.LABEL_FIELD);
			}
			_assumedTextFormat = _labelField.defaultTextFormat;
		}
		override protected function unbindFromAsset():void{
			_labelFieldSizer.assumedPaddingTop = NaN;
			_labelFieldSizer.assumedPaddingLeft = NaN;
			_labelFieldSizer.assumedPaddingBottom = NaN;
			_labelFieldSizer.assumedPaddingRight = NaN;
			
			_labelField.multiline = _assumedMultiline;
			_labelField.wordWrap = _assumedMultiline;
			
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
				var heightWas:Number = _labelField.height;
				
				if(measText!=textWas)_labelField.htmlText = measText;
				if(measWidth){
					if(_backing)_labelField.width = _backing.naturalWidth-_labelFieldSizer.paddingLeft-_labelFieldSizer.paddingRight+TextFieldGutter.TEXT_FIELD_GUTTER*2;
					else _labelField.width = _labelField.naturalWidth;
					
					_measurements.x = _labelField.textWidth+_labelFieldSizer.paddingLeft+_labelFieldSizer.paddingRight;
				}else{
					var width:Number = (_size.x>0?_size.x:_asset.naturalWidth);
					_measurements.x = _size.x;
					_labelField.width = _size.x-_labelFieldSizer.paddingLeft-_labelFieldSizer.paddingRight+TextFieldGutter.TEXT_FIELD_GUTTER*2;
					_labelField.height = _labelField.textHeight+TextFieldGutter.TEXT_FIELD_GUTTER*2; // if height is less than one line then wrapping doesn't occur
				}
				_measurements.y = _labelField.textHeight+_labelFieldSizer.paddingTop+_labelFieldSizer.paddingBottom;
				
				_labelField.width = widthWas;
				_labelField.height = heightWas;
				if(measText!=textWas)_labelField.htmlText = textWas;
			}else{
				invalidateMeasurements();
			}
		}
		override public function setSize(width:Number, height:Number):void{
			if(useMeasuredWidth() && width!=_size.x){
				invalidateMeasurements();
			}
			super.setSize(width, height);
		}
		protected function useMeasuredWidth():Boolean{
			return !(isBound?_labelField.multiline:_multiline);
		}
		protected function getMeasurementText():String{
			return _labelField.htmlText;
		}
		protected function applyFormat() : void{
			if(_labelField){
				var format:TextFormat = getValueOrAssumed(_textFormat,_assumedTextFormat);
				if(format){
					_labelField.defaultTextFormat = format;
					//_labelField.setTextFormat(format);
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
		override protected function commitSize():void{
			super.commitSize();
			
			var labelWidth:Number = size.x-_labelFieldSizer.paddingLeft-_labelFieldSizer.paddingRight+TextFieldGutter.TEXT_FIELD_GUTTER*2;
			var labelHeight:Number = size.y-_labelFieldSizer.paddingTop-_labelFieldSizer.paddingBottom+TextFieldGutter.TEXT_FIELD_GUTTER*2;
			
			if(labelWidth<0)labelWidth = 0;
			if(labelHeight<0)labelHeight = 0;
			
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
		// compares 2 numbers taking floating point errors into account
		private function fleCompare(number1:Number, number2:Number):Boolean{
			var dif:Number = number1-number2;
			return dif<1?(dif>-0.01):(dif<0.01);
		}
		override protected function commitPosition():void{
			if(_labelField==asset){
				asset.setPosition(position.x-TextFieldGutter.TEXT_FIELD_GUTTER+_labelFieldSizer.paddingLeft,position.y-TextFieldGutter.TEXT_FIELD_GUTTER+_labelFieldSizer.paddingTop);
			}else{
				super.commitPosition();
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