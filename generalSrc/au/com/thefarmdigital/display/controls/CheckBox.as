package au.com.thefarmdigital.display.controls{
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import org.farmcode.display.constants.Direction;
	
	public class CheckBox extends CustomButton implements ISelectableControl{
		override public function get autoToggleSelect():Boolean{
			return super.autoToggleSelect;
		}
		override public function set autoToggleSelect(value:Boolean):void{
		}
		[Inspectable(name="Label")]
		public function get label():String{
			return _label;
		}
		public function set label(value:String):void{
			if(_label != value){
				_label = value;
				this.labelText = (value?value:"");
				invalidate();
			}
		}
		[Inspectable(name="Label Placement",defaultValue="right,left,center",type="List")]
		public function get labelPlacement():String{
			return _labelPlacement;
		}
		public function set labelPlacement(value:String):void{
			if(_labelPlacement != value){
				_labelPlacement = value;
				assignAutoSize();
				this.invalidateMeasurements();
				invalidate();
			}
		}
		public function get labelField():TextField{
			return _labelField;
		}
		public function set labelField(value:TextField):void{
			if(_labelField != value){
				addChildTo(this, value);
				_labelField = value;
				if(!childrenConstructed && _labelField.text){
					_labelField.defaultTextFormat = _labelField.getTextFormat()
				}
				this.invalidateMeasurements();
				assignAutoSize();
				this.labelText = _label;
				assessFontColor();
				invalidate();
			}
		}
		public function get labelGap():Number{
			return _labelGap;
		}
		public function set labelGap(value:Number):void{
			if(_labelGap != value){
				_labelGap = value;
				this.invalidateMeasurements();
				invalidate();
			}
		}
		public function get display():DisplayObject{
			return this;
		}
		
		protected var _groupName:String;
		protected var _label:String = "";
		protected var _labelField:TextField;
		protected var _labelPlacement:String;
		protected var _labelGap:Number = 2;
		
		public function CheckBox(){
			super();
			super.autoToggleSelect = true;
		}
		
		protected function set labelText(value: String): void
		{
			if (value!=null && this._labelField)
			{
				var oldWidth:Number = _labelField.width;
				var oldHeight:Number = _labelField.height;
				_labelField.htmlText = value;
				if(oldWidth!=_labelField.width || oldHeight!=_labelField.height){
					this.invalidateMeasurements();
				}
			}
		}
		
		override protected function measure(): void
		{
			var stateWidth: Number = 0;
			var stateHeight: Number = 0;
			var labelWidth: Number = 0;
			var labelHeight: Number = 0;
			if (this.currentState != null && this.currentState.background != null)
			{
				stateWidth = this.currentState.background.width;
				stateHeight = this.currentState.background.height;
			}
			if (this.labelField != null)
			{
				labelWidth = this.labelField.width;
				labelHeight = this.labelField.height;
			}
			if(this.labelDirection == Direction.VERTICAL)
			{
				_measuredWidth = Math.max(stateWidth, labelWidth);
				_measuredHeight = stateHeight + labelHeight;
				if (stateHeight > 0 || labelHeight > 0)
				{
					_measuredHeight += _labelGap
				}
			}
			else
			{
				_measuredWidth = stateWidth + labelWidth;
				if (stateWidth > 0 || labelWidth > 0)
				{
					_measuredWidth += _labelGap;
				}
				_measuredHeight = Math.max(stateHeight, labelHeight);
			}
		}
		
		protected function get labelDirection(): String
		{
			var direction: String = Direction.HORIZONTAL;
			if (this._labelPlacement == TextFormatAlign.JUSTIFY || 
				this._labelPlacement == TextFormatAlign.CENTER)
			{
				direction = Direction.VERTICAL;
			}
			return direction;
		}
		
		override protected function commitHeirarchy():void{
			if(labelField){
				labelField.wordWrap = false;
				var format:TextFormat = labelField.defaultTextFormat;
				if(!_labelPlacement)labelPlacement = (format.align==TextFormatAlign.RIGHT?TextFormatAlign.LEFT:(format.align==TextFormatAlign.LEFT?TextFormatAlign.RIGHT:format.align));
				if(_upState){
					switch(_labelPlacement){
						case TextFormatAlign.LEFT:
							_labelGap = -labelField.x-labelField.width+_upState.x;
							break;
						case TextFormatAlign.CENTER:
						case TextFormatAlign.JUSTIFY:
							_labelGap = labelField.y-_upState.y-_upState.height;
							break;
					default:
							_labelGap = labelField.x-_upState.x-_upState.width;
							break;
					}
					var state:VisualState = getState(UP_STATE);
					state.fontColor = (format.color as Number);
				}
			}else{
				if(!_labelPlacement)labelPlacement = TextFormatAlign.RIGHT;
			}
			super.commitHeirarchy();
		}
		override protected function draw():void{
			super.draw();
			if(labelField){
				placeLabel();
			}
		}
		protected function placeLabel():void{
			if(currentState){
				var bounds:Rectangle = currentState.background.getBounds(this);
				labelField.y = bounds.y+(bounds.height-labelField.height)/2;
				switch(_labelPlacement){
					case TextFormatAlign.LEFT:
						labelField.x = bounds.x-labelField.width-_labelGap;
						break;
					case TextFormatAlign.CENTER:
					case TextFormatAlign.JUSTIFY:
						labelField.x = bounds.x+(bounds.width-labelField.width)/2;
						labelField.y = bounds.y+bounds.height+_labelGap;
						break;
					default:
						labelField.x = bounds.x+bounds.width+_labelGap;
						break;
				}
			}
		}
		override protected function showState(state:VisualState):void{
			super.showState(state);
			assessFontColor();
		}
		protected function assessFontColor():void{
			if(labelField){
				var targetColor: Number = NaN;
				var upState:VisualState = getState(UP_STATE);
				if(currentState && !isNaN(currentState.fontColor)){
					targetColor = currentState.fontColor;
				}else if(upState && !isNaN(upState.fontColor)){
					targetColor = upState.fontColor;
				}
				if(!isNaN(targetColor)){
					var defFormat: TextFormat = this.labelField.defaultTextFormat;
					defFormat.color = targetColor;
					this.labelField.defaultTextFormat = defFormat;
					for (var i: uint = 0; i < this.labelField.text.length; ++i)
					{
						var format: TextFormat = labelField.getTextFormat(i, i + 1);
						format.color = targetColor;
						labelField.setTextFormat(format, i, i + 1);
						// Makes sure that italics, etc are applied still for each html character
					}
				}
			}
		}
		protected function assignAutoSize():void{
			if(_labelPlacement && labelField){
				switch(_labelPlacement){
					case TextFormatAlign.LEFT:
						labelField.autoSize = TextFormatAlign.RIGHT;
						break;
					case TextFormatAlign.RIGHT:
						labelField.autoSize = TextFormatAlign.LEFT;
						break;
					default:
						labelField.autoSize = _labelPlacement;
						break;
				}
			}
		}
	}
}