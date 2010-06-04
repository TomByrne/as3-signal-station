package au.com.thefarmdigital.display.controls
{
	
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * The Button control lays out a text label, icon and background DisplayObject to form a button.
	 * If you're after a more visually customised button, see the CustomButton class.
	 * 
	 * @see au.com.thefarmdigital.display.controls.CustomButton
	 */
	public class Button extends CheckBox{
		private static const TEXT_FIELD_GUTTER:Number = 2;
		
		[Inspectable(defaultValue=false, type="Boolean", name="Togglable")]
		override public function get autoToggleSelect():Boolean{
			return super.autoToggleSelect;
		}
		override public function set autoToggleSelect(value:Boolean):void{
			super.autoToggleSelect = value;
		}
		
		public function get icon():DisplayObject{
			return _icon;
		}
		public function set icon(value:DisplayObject):void{
			if(_icon != value){
				if(_icon){
					removeChild(_icon);
				}
				_icon = value;
				if(value){
					if(value.parent && value.parent!=this)value.parent.removeChild(value);
					if(!value.parent)addChild(value);
				}
				this.invalidateMeasurements();
				invalidate();
			}
		}
		public function get labelPadding():Rectangle{
			return _labelPadding;
		}
		public function set labelPadding(value:Rectangle):void{
			if(_labelPadding != value){
				_labelPadding = value;
				this.invalidateMeasurements();
				invalidate();
			}
		}
		
		protected var _labelPadding:Rectangle = new Rectangle(2,2,2,2);
		protected var _iconGap:Number = 2;
		protected var _icon:DisplayObject;
				
		public function Button(){
			super();
			this.autoToggleSelect = false;
		}
		override protected function measure(): void
		{
			var iconWidth:Number = 0;
			if(icon && (_labelPlacement==TextFormatAlign.LEFT || _labelPlacement==TextFormatAlign.RIGHT)){
				iconWidth = _iconGap+icon.width;
			}
			var actualTextWidth: Number = _labelField.textWidth;
			this._measuredWidth = actualTextWidth+_labelPadding.x+_labelPadding.width+iconWidth;
			
			var iconHeight:Number = 0;
			if(icon){
				iconHeight = icon.height;
				if(_labelPlacement==TextFormatAlign.CENTER || _labelPlacement==TextFormatAlign.JUSTIFY)iconHeight += _iconGap
			}
			this._measuredHeight = _labelField.textHeight+_labelPadding.y+_labelPadding.height+iconHeight;
			// TODO: Should use currentState or the default state if upState null?
			if (this.upState != null)
			{
				this._measuredWidth = Math.max(this._measuredWidth, this.upState.width);
				this._measuredHeight = Math.max(this._measuredHeight, this.upState.height);
			}
		}
		
		override protected function commitHeirarchy():void{
			if(_labelField){
				_labelField.wordWrap = false;
				var oldText:String = _labelField.htmlText;
				_labelField.text = "lj"; // Junk characters to give the text field a proper height
				if(_icon){
					if(_icon.x>_labelField.x){
						if(!_labelPlacement)_labelPlacement = TextFormatAlign.LEFT;
						_iconGap = Math.max(_icon.x-_labelField.x-_labelField.width,0);
					}else{
						if(!_labelPlacement)_labelPlacement = TextFormatAlign.RIGHT;
						_iconGap = Math.max(_labelField.x-_icon.x-_icon.width,0);
					}
				}
				if(_upState){
					var b1:Rectangle = _upState.getBounds(this);
					var b2:Rectangle = _labelField.getBounds(this);
					if(_icon){
						var b3:Rectangle = _icon.getBounds(this);
						var realBounds:Rectangle = new Rectangle();
						realBounds.x = Math.min(b2.x,b3.x);
						realBounds.y = Math.min(b2.y,b3.y);
						realBounds.width = Math.max(b2.x+b2.width,b3.x+b3.width)-realBounds.x;
						realBounds.height = Math.max(b2.y+b2.height,b3.y+b3.height)-realBounds.y;
						b2 = realBounds;
					}
					_labelPadding = new Rectangle(b2.x-b1.x,b2.y-b1.y,(b1.x+b1.width)-(b2.x+b2.width),(b1.y+b1.height)-(b2.y+b2.height));
				}
				_labelField.htmlText = oldText;
			}else if(_icon){
				_iconGap = _icon.x;
			}
			super.commitHeirarchy();
		}
		override protected function draw():void{
			super.draw();
			if(currentState && currentState.background){
				currentState.background.x = 0;
				currentState.background.y = 0;
				currentState.background.width = width;
				currentState.background.height = height;
			}
			if(!labelField && _icon){
				_icon.y = Math.round((height-_icon.height)/2);
				switch(_labelPlacement){
					case TextFormatAlign.LEFT:
						_icon.x = Math.round(width-_icon.width-_iconGap);
						break;
					case TextFormatAlign.CENTER:
					case TextFormatAlign.JUSTIFY:
						_icon.x = Math.round((width-_icon.width)/2);
						break;
					default:
						_icon.x = Math.round(_iconGap);
						break;
				}
			}
		}
		override protected function placeLabel():void{
			var labelWidth:Number = width-_labelPadding.x-_labelPadding.width;
			var labelHeight:Number = height-_labelPadding.y-_labelPadding.height;
			if(_icon){
				if(_labelPlacement==TextFormatAlign.LEFT || _labelPlacement==TextFormatAlign.RIGHT){
					labelWidth -= _icon.width+_iconGap;
				}else{
					labelHeight -= _icon.height+_iconGap;
				}
			}
			var textPadding:Rectangle = new Rectangle(TEXT_FIELD_GUTTER,TEXT_FIELD_GUTTER,TEXT_FIELD_GUTTER,TEXT_FIELD_GUTTER);
			
			var overflow:Number = Math.min(width-(_labelPadding.x+_labelPadding.width+textPadding.x+textPadding.width+_labelField.textWidth),0);
			_labelField.x = _labelPadding.x-textPadding.x+overflow/2;
			_labelField.width = labelWidth+textPadding.x+textPadding.width-overflow;
			
			overflow = Math.min(height-(_labelPadding.y+_labelPadding.height+textPadding.y+textPadding.height+_labelField.textHeight),0);
			_labelField.y = _labelPadding.y-textPadding.y+overflow/2;
			_labelField.height = labelHeight+textPadding.y+textPadding.height-overflow;
			
			var textAlign: String = null;
			if(_icon){
				switch(_labelPlacement){
					case TextFormatAlign.LEFT:
						_icon.x = Math.round(_labelPadding.x+labelWidth+_iconGap);
						_icon.y = Math.round(_labelPadding.y+(labelHeight-_icon.height)/2);
						break;
					case TextFormatAlign.CENTER:
					case TextFormatAlign.JUSTIFY:
						_icon.x = Math.round(_labelPadding.x+(labelWidth-_icon.width)/2);
						_icon.y = Math.round(_labelPadding.y+labelHeight+_iconGap);
						break;
					default:
						_icon.x = Math.round(_labelPadding.x);
						_icon.y = Math.round(_labelPadding.y+(labelHeight-_icon.height)/2);
						_labelField.x = _icon.x+_icon.width+_iconGap;
						break;
				}
			}
			var fieldBounds:Rectangle = _labelField.getBounds(_labelField);
			_labelField.y += Math.max(((_labelField.height+(fieldBounds.y*2))-_labelField.textHeight)/2,0);
			// Alignment should be determined by the field itself
			//this.alignment = textAlign;
		}
		protected function set alignment(alignment:String):void{
			var format:TextFormat = _labelField.defaultTextFormat;
			format.align = alignment;
			_labelField.setTextFormat(format);
			_labelField.defaultTextFormat = format;
		}
		override protected function assignAutoSize():void{
			if(_labelField)_labelField.autoSize = TextFieldAutoSize.NONE;
		}
		
		override protected function showState(state:VisualState):void{
			super.showState(state);
			
			if (this._icon is StateControl)
			{
				var sIcon: StateControl = this._icon as StateControl;
				sIcon.applyState(state.name);
			}
		}
		override protected function showStateList(stateList:Array):VisualState
		{			
			var resultState: VisualState = super.showStateList(stateList);
			
			if (this._icon is StateControl)
			{
				var sIcon: StateControl = this._icon as StateControl;
				sIcon.applyStateList(stateList);
			}
			
			return resultState;
		}
		override protected function hideState(state:VisualState):void{
			super.hideState(state);
			
			if (this._icon is StateControl)
			{
				var sIcon: StateControl = this._icon as StateControl;
				sIcon.applyState(state.name);
			}
		}
	}
}