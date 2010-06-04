package au.com.thefarmdigital.display.controls
{
	import au.com.thefarmdigital.events.ControlEvent;
	import au.com.thefarmdigital.validation.ValidationEvent;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import org.farmcode.display.constants.Direction;
	
	[Event(type="au.com.thefarmdigital.events.ControlEvent", name="valueChange")]
	public class Slider extends Control
	{
		public function get backing():DisplayObject{
			return _backing;
		}
		public function set backing(value:DisplayObject):void{
			if(_backing != value){
				if(value.parent && value.parent!=this)value.parent.removeChild(value);
				if(!value.parent)addChild(value);
				_backing = value;
				invalidate();
			}
		}
		public function get thumb():Sprite{
			return _thumb;
		}
		public function set thumb(value:Sprite):void{
			if(_thumb != value){
				if(value.parent && value.parent!=this)value.parent.removeChild(value);
				if(!value.parent)addChild(value);
				_thumb = value;
				_thumb.buttonMode = true;
				_thumb.addEventListener(MouseEvent.MOUSE_DOWN,mouseDownHandler);
				invalidate();
			}
		}
		public function get value():Number{
			return _value;
		}
		public function set value(value:Number):void {
			value = Math.min(Math.max(value,0),1);
			if(_value != value){
				_value = _drawValue = value;
				invalidate();
				dispatchEvent(new ValidationEvent(ValidationEvent.VALIDATION_VALUE_CHANGED));
			}
		}
		
		override public function getValidationValue(validityKey:String=null):*{
			return value;
		}
		override public function setValidationValue(value:*, validityKey:String=null):void{
			this.value = value;
		}
		
		[Inspectable(name="Direction", defaultValue="horizontal,vertical",type="List")]
		public function get direction():String{
			return _direction;
		}
		public function set direction(value:String):void{
			if(_direction != value){
				_direction = value;
				invalidate();
			}
		}
		
		[Inspectable(name="Padding Fore", defaultValue="0",type="Number")]
		public function get paddingFore():Number{
			return _paddingFore;
		}
		public function set paddingFore(value:Number):void{
			if(_paddingFore != value){
				_paddingFore = value;
				invalidate();
			}
		}
		
		[Inspectable(name="Padding Aft", defaultValue="0",type="Number")]
		public function get paddingAft():Number{
			return _paddingAft;
		}
		public function set paddingAft(value:Number):void{
			if(_paddingAft != value){
				_paddingAft = value;
				invalidate();
			}
		}
		public function get decrementButton():CustomButton{
			return _decrementButton;
		}
		public function set decrementButton(value:CustomButton):void{
			if (_decrementButton != value) {
				if (_decrementButton) {
					_decrementButton.removeEventListener(MouseEvent.CLICK, this.clickHandler);
				}
				_decrementButton = value;
				if(value.parent && value.parent!=this)value.parent.removeChild(value);
				if (!value.parent) addChild(value);
				_decrementButton.buttonMode = true;
				_decrementButton.addEventListener(MouseEvent.CLICK, this.clickHandler);
			}
		}
		public function get incrementButton():CustomButton{
			return _incrementButton;
		}
		public function set incrementButton(value:CustomButton):void{
			if(_incrementButton != value){
				if (_incrementButton) {
					_incrementButton.removeEventListener(MouseEvent.CLICK, this.clickHandler);
				}
				_incrementButton = value;
				if(value.parent && value.parent!=this)value.parent.removeChild(value);
				if (!value.parent) addChild(value);
				_incrementButton.buttonMode = true;
				_incrementButton.addEventListener(MouseEvent.CLICK, this.clickHandler);
				invalidate();
			}
		}
		[Inspectable(name="Increment Step",defaultValue="0.1",type="Number")]
		public function get incrementStep():Number{
			return _incrementStep;
		}
		public function set incrementStep(value:Number):void{
			if(_incrementStep != value){
				_incrementStep = Math.min(1, Math.max(0.01, value));
			}
		}
		[Inspectable(name="Button Padding",defaultValue="0",type="Number")]
		public function get buttonPadding():Number{
			return _buttonPadding;
		}
		public function set buttonPadding(value:Number):void{
			if(_buttonPadding != value){
				_buttonPadding = value;
			}
		}
		
		protected var _backing:DisplayObject;
		protected var _thumb:Sprite;
		protected var _value:Number = 0;
		protected var _drawValue:Number = 0;
		protected var _dragOffset:Number;
		protected var _direction:String = Direction.HORIZONTAL;
		protected var _paddingFore:Number = 0;
		protected var _paddingAft:Number = 0;
		protected var _incrementButton: CustomButton;
		protected var _decrementButton: CustomButton;
		protected var _incrementStep: Number = 0.1;
		protected var _buttonPadding: Number = 0;
		
		public var immediateValueUpdate:Boolean = false;
		
		public function Slider(){
			addEventListener(MouseEvent.MOUSE_DOWN,mouseDownHandler);
		}
		protected function clickHandler(e: MouseEvent): void {
			switch (e.currentTarget) {
				case	_decrementButton:
					shiftValue(-_incrementStep);
					break;
				case	_incrementButton:
					shiftValue(_incrementStep);
					break;
			}
		}
		/**
		 * Moves the current value by the specified amount from its current position.
		 * @param	amount	The amount to move as a percentage: 0-1
		 */
		public function shiftValue(amount: Number): void {
			if (amount != 0) {
				setValue(value + amount);
			}
		}
		protected function mouseDownHandler(e:MouseEvent):void{
			e.stopPropagation();
			if (e.currentTarget == _decrementButton || e.currentTarget == _incrementButton) {
				// Do nothing, click will be handled by click event for decrement and increment
			}else if (e.currentTarget == _thumb) {
				stage.addEventListener(MouseEvent.MOUSE_UP,mouseUpHandler);
				stage.addEventListener(MouseEvent.MOUSE_MOVE,mouseMoveHandler);
				
				if(_direction==Direction.VERTICAL){
					_dragOffset = mouseY-_thumb.y;
					if (_decrementButton) {
						_dragOffset -= (_decrementButton.height + _buttonPadding);
					}
				}else{
					_dragOffset = mouseX - _thumb.x;
					if (_decrementButton) {
						_dragOffset += (_decrementButton.width + _buttonPadding);
					}
				}
				mouseMoveHandler();
			}else {
				stage.addEventListener(MouseEvent.MOUSE_UP,mouseUpHandler);
				stage.addEventListener(MouseEvent.MOUSE_MOVE,mouseMoveHandler);
				_dragOffset = NaN;
				mouseMoveHandler();
			}
		}
		protected function mouseMoveHandler(e:MouseEvent = null):void {
			if(_direction==Direction.VERTICAL){
				if(isNaN(_dragOffset)) _drawValue = (mouseY-_paddingFore)/(_backing.height-_thumb.height-_paddingFore-_paddingAft);
				else _drawValue = (mouseY-_dragOffset-_paddingFore)/(_backing.height-_thumb.height-_paddingFore-_paddingAft);
			}else{
				if(isNaN(_dragOffset))_drawValue = (mouseX-_paddingFore)/(_backing.width-_thumb.width-_paddingFore-_paddingAft);
				else _drawValue = (mouseX-_dragOffset-_paddingFore)/(_backing.width-_thumb.width-_paddingFore-_paddingAft);
			}
			_drawValue = Math.min(Math.max(_drawValue,0),1);
			if(immediateValueUpdate){
				setValue(_drawValue);
			}else{
				validate(true);
			}
		}
		protected function mouseUpHandler(e:MouseEvent):void{
			setValue(_drawValue);
			stage.removeEventListener(MouseEvent.MOUSE_UP,mouseUpHandler);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE,mouseMoveHandler);
		}
		/**
		 * Notifies listeners that the slider value has changed
		 */
		protected function dispatchValueChangeEvent(): void {
			dispatchEvent(new ControlEvent(ControlEvent.VALUE_CHANGE));
			dispatchEvent(new ValidationEvent(ValidationEvent.VALIDATION_VALUE_CHANGED));
		}
		protected function setValue(to:Number):void{
			value = to;
			dispatchValueChangeEvent();
		}
		override protected function draw():void{
			if(_direction==Direction.VERTICAL){
				_backing.height = height;
				var maxSize:Number = Math.max(_backing.width,_thumb?_thumb.width:0);
				_backing.x = (maxSize-_backing.width)/2;
				_backing.y = 0;
				
				if(_thumb){
					_thumb.x = (maxSize-_thumb.width)/2;
					var range:Number = _backing.height-_thumb.height-_paddingFore-_paddingAft;
					_thumb.y = _paddingFore+(range*_drawValue);
				}
			}else {
				var backingWidth: Number = width;
				
				var maxHeight: Number = Math.max(_backing.height,_thumb?_thumb.height:0);
				_backing.y = (maxHeight-_backing.height)/2;
				if (_decrementButton) {
					var backingOffset: Number = _decrementButton.width + _buttonPadding;
					backingWidth -= backingOffset;
				} 
				if (_incrementButton) {
					backingWidth -= (_incrementButton.width + _buttonPadding);
				}
				
				_backing.width = backingWidth;
				
				if (_decrementButton) {
					_decrementButton.x = 0;
					_backing.x = _decrementButton.width + _buttonPadding;
				}else {
					_backing.x = 0;
				}
				if (_incrementButton) {
					_incrementButton.x = _backing.x + _backing.width + _buttonPadding;
				}
				
				if(_thumb){
					_thumb.y = (maxHeight-_thumb.height)/2;
					range = _backing.width - _thumb.width - _paddingFore - _paddingAft;
					var thumbX: Number = _paddingFore + (range * _drawValue);
					if (_decrementButton) {
						thumbX += (_decrementButton.width + _buttonPadding);
					}
					_thumb.x = Math.round(thumbX);
				}
			}
		}
	}
}