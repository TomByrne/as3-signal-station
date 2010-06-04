package org.farmcode.display.controls
{
	import flash.display.DisplayObject;
	import flash.display.TextFieldGutter;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	
	import org.farmcode.data.dataTypes.IStringProvider;
	import org.farmcode.data.dataTypes.IValueProvider;
	import org.farmcode.display.DisplayNamespace;
	import org.farmcode.display.assets.IAsset;
	import org.farmcode.display.assets.IDisplayAsset;
	import org.farmcode.display.assets.ITextFieldAsset;
	
	use namespace DisplayNamespace;
	
	//TODO: combine duplicated functionality from TextInput
	public class TextLabel extends Control
	{
		DisplayNamespace static const LABEL_FIELD_CHILD:String = "labelField";
		DisplayNamespace static const LABEL_BACKING_CHILD:String = "labelBacking";
		
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
		protected var _labelField:ITextFieldAsset;
		protected var _labelBacking:IDisplayAsset;
		
		public function TextLabel(asset:IDisplayAsset=null){
			super(asset);
		}
		protected function onProviderChanged(... params):void{
			if(_labelField)commitText();
		}
		protected function commitText():void{
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
			if(_labelField.htmlText != newText){
				_labelField.htmlText = newText;
				dispatchMeasurementChange();
			}
		}
		override protected function bindToAsset():void{
			_labelField = (asset as ITextFieldAsset);
			if(_labelField){
				_labelBacking = null;
			}else{
				_labelField = _containerAsset.takeAssetByName(LABEL_FIELD_CHILD, ITextFieldAsset);
				_labelBacking = _containerAsset.takeAssetByName(LABEL_BACKING_CHILD, IDisplayAsset, true);
			}
			if(_labelBacking){
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
				
				_assumedPaddingTop = (_labelField.y+TextFieldGutter.TEXT_FIELD_GUTTER)-_labelBacking.y;
				_assumedPaddingLeft = (_labelField.x+TextFieldGutter.TEXT_FIELD_GUTTER)-_labelBacking.x;
				_assumedPaddingBottom = (_labelBacking.y+_labelBacking.height)-(_labelField.y+TextFieldGutter.TEXT_FIELD_GUTTER+operableHeight);
				_assumedPaddingRight = (_labelBacking.x+_labelBacking.width)-(_labelField.x+TextFieldGutter.TEXT_FIELD_GUTTER+operableWidth);
			}else{
				_assumedPaddingTop = 0;
				_assumedPaddingLeft = 0;
				_assumedPaddingBottom = 0;
				_assumedPaddingRight = 0;
			}
			if(_data && _labelField)commitText();
		}
		override protected function unbindFromAsset():void{
			if(_labelField!=asset){
				_containerAsset.returnAsset(_labelField);
				_labelField = null;
			}
			if(_labelBacking){
				_containerAsset.returnAsset(_labelBacking);
				_labelBacking = null;
			}
		}
		override protected function measure():void{
			checkIsBound();
			if(asset){
				var paddingTop:Number = (isNaN(_paddingTop)?_assumedPaddingTop:_paddingTop);
				var paddingBottom:Number = (isNaN(_paddingBottom)?_assumedPaddingBottom:_paddingBottom);
				var paddingLeft:Number = (isNaN(_paddingLeft)?_assumedPaddingLeft:_paddingLeft);
				var paddingRight:Number = (isNaN(_paddingRight)?_assumedPaddingRight:_paddingRight);
				
				var widthWas:Number = _labelField.width;
				if(_labelBacking)_labelField.width = _labelBacking.naturalWidth-paddingLeft-paddingRight+TextFieldGutter.TEXT_FIELD_GUTTER*2;
				else _labelField.width = _labelField.naturalWidth;
				if(!_displayMeasurements)_displayMeasurements = new Rectangle();
				_displayMeasurements.width = _labelField.textWidth+paddingLeft+paddingRight;
				_displayMeasurements.height = _labelField.textHeight+paddingTop+paddingBottom;
				_labelField.width = widthWas;
			}else{
				_measureFlag.invalidate();
			}
		}
		override protected function draw():void{
			var paddingTop:Number = (isNaN(_paddingTop)?_assumedPaddingTop:_paddingTop);
			var paddingBottom:Number = (isNaN(_paddingBottom)?_assumedPaddingBottom:_paddingBottom);
			var paddingLeft:Number = (isNaN(_paddingLeft)?_assumedPaddingLeft:_paddingLeft);
			var paddingRight:Number = (isNaN(_paddingRight)?_assumedPaddingRight:_paddingRight);
			
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
			
			if(_labelBacking){
				_labelBacking.width = displayPosition.width;
				_labelBacking.height = displayPosition.height;
			}
		}
		override protected function positionAsset():void{
			var paddingTop:Number = (isNaN(_paddingTop)?_assumedPaddingTop:_paddingTop);
			var paddingBottom:Number = (isNaN(_paddingBottom)?_assumedPaddingBottom:_paddingBottom);
			var paddingLeft:Number = (isNaN(_paddingLeft)?_assumedPaddingLeft:_paddingLeft);
			var paddingRight:Number = (isNaN(_paddingRight)?_assumedPaddingRight:_paddingRight);
			
			if(_labelField==asset){
				asset.x = displayPosition.x-TextFieldGutter.TEXT_FIELD_GUTTER+paddingLeft;
				asset.y = displayPosition.y-TextFieldGutter.TEXT_FIELD_GUTTER+paddingTop;
			}else{
				super.positionAsset();
				_labelField.x = -TextFieldGutter.TEXT_FIELD_GUTTER+paddingLeft;
				_labelField.y = -TextFieldGutter.TEXT_FIELD_GUTTER+paddingTop;
			}
		}
	}
}