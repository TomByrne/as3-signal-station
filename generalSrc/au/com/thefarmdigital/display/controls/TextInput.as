package au.com.thefarmdigital.display.controls{
	import au.com.thefarmdigital.display.scrolling.IScrollable;
	import au.com.thefarmdigital.events.ControlEvent;
	import au.com.thefarmdigital.structs.ScrollMetrics;
	import au.com.thefarmdigital.validation.ValidationEvent;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.display.constants.Direction;
	
	public class TextInput extends StateControl implements IScrollable{
		
		// States
		public static var NORMAL_STATE:String = "normalState";
		public static var HIGHLIGHT_STATE:String = "highlightState";
		public static var INACTIVE_STATE:String = "inactiveState";
		
		[Inspectable(name="Text", defaultValue="")]
		public function get text():String{
			return (showingPrompt?"":(field?field.text:_text));
		}
		public function set text(to:String):void{
			_text = to;
			if((to && to.length) || hasFocus){
				if(field){
					if(to)field.text = to;
					else  field.text = "";
					if(_scrollMetricsChanged)_scrollMetricsChanged.perform(this, Direction.VERTICAL, getScrollMetrics(Direction.VERTICAL));
				}
				showingPrompt = false;
				checkInsert();
			}else if(!showingPrompt){
				showingPrompt = true;
				if(field)field.text = _prompt;
			}
			this.field.scrollH = 0;
			dispatchEvent(new ValidationEvent(ValidationEvent.VALIDATION_VALUE_CHANGED));
		}
		
		[Inspectable(name="Display As Password", defaultValue=false)]
		public function get displayAsPassword():Boolean{
			return _displayAsPassword;
		}
		public function set displayAsPassword(to:Boolean):void{
			_displayAsPassword = to;
			if(field)field.displayAsPassword = to;
		}
		
		[Inspectable(name="Active", defaultValue=true)]
		public function get active():Boolean{
			return _active;
		}
		public function set active(to:Boolean):void{
			_active = to;
			if(field)field.type = (_active?TextFieldType.INPUT:TextFieldType.DYNAMIC);
			invalidate();
		}
		[Inspectable(name="Restrict", defaultValue="")]
		public function get restrict():String{
			return _restrict;
		}
		public function set restrict(to:String):void{
			_restrict = to;
			if (to == "")
			{
				to = null;
			}
			if(field)field.restrict = to;
		}
		
		[Inspectable(name="Max Chars", defaultValue=0)]
		public function get maxChars():Number{
			return _maxChars;
		}
		public function set maxChars(to:Number):void{
			_maxChars = to;
			if(field)field.maxChars = to;
		}
		override public function get tabIndex():int{
			return _tabIndex;
		}
		override public function set tabIndex(to:int):void{
			_tabIndex = to;
			if(field)field.tabIndex = to;
		}
		public function get multiline():Boolean{
			return _multiline;
		}
		public function set multiline(to:Boolean):void{
			_multiline = to;
			if(field)field.multiline = field.wordWrap = to;
		}
		[Inspectable]
		public function get prompt():String{
			return _prompt;
		}
		public function set prompt(to:String):void{
			if(_prompt!=to){
				_prompt = (to?to:"");
				if(showingPrompt && field)field.text = to;
			}
		}
		public function get fieldPadding():Rectangle{
			return _fieldPadding;
		}
		public function set fieldPadding(to:Rectangle):void{
			if(_fieldPadding!=to){
				_fieldPadding = to;
				invalidate();
			}
		}
		public function get field():TextField{
			return _field;
		}
		public function set field(to:TextField):void{
			if (_field) {
				_field.removeEventListener(FocusEvent.FOCUS_IN,setFocusHandler);
				_field.removeEventListener(FocusEvent.FOCUS_OUT,killFocusHandler);
				_field.removeEventListener(Event.CHANGE,onChange);
			}
			if(_field!=to){
				_field = to;
				_field.type = (_active?TextFieldType.INPUT:TextFieldType.DYNAMIC);
				_field.addEventListener(FocusEvent.FOCUS_IN,setFocusHandler);
				_field.addEventListener(FocusEvent.FOCUS_OUT,killFocusHandler);
				_field.addEventListener(Event.CHANGE,onChange);
				_field.text = (showingPrompt?_prompt:(_text?_text:""));
				_field.multiline = _field.wordWrap = _multiline;
				_field.tabIndex = _tabIndex;
				_field.maxChars = this.maxChars;
				_field.restrict = _restrict;
				_field.displayAsPassword = _displayAsPassword;
				_field.addEventListener(Event.SCROLL,onScroll);
				if(_field.parent!=this)addChild(_field);
				invalidate();
			}
		}
		public function get normalState():DisplayObject{
			return _normalState;
		}
		public function set normalState(to:DisplayObject):void{
			if(_normalState!=to){
				removeState(NORMAL_STATE);
				_normalState = to;
				addState(new VisualState(NORMAL_STATE,to));
				invalidate();
			}
		}
		public function get highlightState():DisplayObject{
			return _highlightState;
		}
		public function set highlightState(to:DisplayObject):void{
			if(_highlightState!=to){
				removeState(HIGHLIGHT_STATE);
				_highlightState = to;
				addState(new VisualState(HIGHLIGHT_STATE,to));
				invalidate();
			}
		}
		public function get inactiveState():DisplayObject{
			return _inactiveState;
		}
		public function set inactiveState(to:DisplayObject):void{
			if(_inactiveState!=to){
				removeState(INACTIVE_STATE);
				_inactiveState = to;
				addState(new VisualState(INACTIVE_STATE,to));
				invalidate();
			}
		}
		public function get fontColor():Number{
			return _fontColor;
		}
		public function set fontColor(to:Number):void{
			if(_fontColor!=to){
				_fontColor = to;
				if(_field){
					var format:TextFormat = _field.defaultTextFormat;
					format.color = _fontColor;
					_field.defaultTextFormat = format;
					_field.setTextFormat(format);
				}
				invalidate();
			}
		}
		public function get insert():Boolean{
			return _insert;
		}
		public function set insert(value:Boolean):void{
			if(_insert!=value){
				_insert = value;
				checkInsert();
			}
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get scrollMetricsChanged():IAct{
			if(!_scrollMetricsChanged)_scrollMetricsChanged = new Act();
			return _scrollMetricsChanged;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get mouseWheel():IAct{
			if(!_mouseWheel)_mouseWheel = new Act();
			return _mouseWheel;
		}
		
		protected var _mouseWheel:Act;
		protected var _scrollMetricsChanged:Act;
		
		protected var _normalState:DisplayObject;
		protected var _highlightState:DisplayObject;
		protected var _inactiveState:DisplayObject;
		
		protected var _field:TextField;
		protected var _fieldPadding:Rectangle;
		protected var hasFocus:Boolean = false;
		protected var showingPrompt:Boolean = true;
		protected var _prompt:String = "";
		protected var _text:String = "";
		protected var _multiline:Boolean = false;
		protected var _tabIndex:int = -1;
		protected var _maxChars:Number;
		protected var _restrict:String;
		protected var _fontColor:Number = 0;
		protected var _displayAsPassword:Boolean = false;
		protected var _active:Boolean = true;
		protected var _insert:Boolean = false;
		
		public function TextInput(){
			super();
			if(_field){
				_fontColor = (_field.defaultTextFormat.color as Number);
				if(_normalState){
					_fieldPadding = new Rectangle(_field.x,_field.y,_normalState.x+_normalState.width-(_field.x+_field.width),_normalState.y+_normalState.height-(_field.y+_field.height));
				}
			}
		}
		
		override public function getValidationValue(validityKey:String=null):*{
			return text;
		}
		override public function setValidationValue(value:*, validityKey:String=null):void{
			text = value;
		}
		
		override public function clear():void{
			text = "";
		}
		override public function setFocus():void{
			if(stage && field)stage.focus = field;
		}
		protected function keyUpHandler(e:KeyboardEvent):void{
			if(e.charCode == Keyboard.ENTER){
				stage.removeEventListener(KeyboardEvent.KEY_UP,keyUpHandler);
				dispatchEvent(e);
				stage.addEventListener(KeyboardEvent.KEY_UP,keyUpHandler);
			}
		}
		protected function onChange(event: Event): void {
			event.stopImmediatePropagation();
			dispatchEvent(new ControlEvent(ControlEvent.VALUE_CHANGE));
			dispatchEvent(new ValidationEvent(ValidationEvent.VALIDATION_VALUE_CHANGED));
			checkInsert();
		}
		protected function setFocusHandler(e:FocusEvent):void{
			hasFocus = true;
			stage.addEventListener(KeyboardEvent.KEY_UP,keyUpHandler);
			if(showingPrompt){
				showingPrompt = false;
				field.text = "";
			}
		}
		protected function killFocusHandler(e:FocusEvent):void{
			hasFocus = false;
			if(field.text == ""){
				showingPrompt = true;
				field.text = _prompt;
			}
			stage.removeEventListener(KeyboardEvent.KEY_UP,keyUpHandler);
			if(_highlit){
				_highlit = false;
				invalidate();
			}
		}
		protected function onScroll(e:Event):void{
			if(_scrollMetricsChanged)_scrollMetricsChanged.perform(this, Direction.VERTICAL, getScrollMetrics(Direction.VERTICAL));
		}
		override protected function draw():void{
			super.draw();
			var state:DisplayObject = showStateList(_active?_highlit?[HIGHLIGHT_STATE,NORMAL_STATE]:[NORMAL_STATE]:[INACTIVE_STATE,NORMAL_STATE]).background;
			if(state){
				state.width = width;
				state.height = height;
			}
			if(field){
				if(fieldPadding){
					field.x = fieldPadding.x;
					field.y = fieldPadding.y;
					field.width = width-fieldPadding.x-fieldPadding.width;
					field.height = height-fieldPadding.y-fieldPadding.height;
				}else{
					field.x = 0;
					field.y = 0;
					field.width = width;
					field.height = height;
				}
			}
		}
		protected function checkInsert():void{
			if(_insert && hasFocus && (_field.selectionBeginIndex==_field.selectionEndIndex && _field.selectionBeginIndex==_field.caretIndex)){
				_field.setSelection(_field.selectionBeginIndex,_field.selectionBeginIndex+1)
			}
		}
		
		// IScrollable implementation
		public function isScrollable(direction:String):Boolean{
			if(_multiline && direction==Direction.VERTICAL){
				return true;
			}else{
				return false;
			}
		}
		public function addScrollWheelListener(direction:String):Boolean{
			return false;
		}
		public function getScrollMetrics(direction:String):ScrollMetrics{
			if(direction==Direction.VERTICAL){
				var ret:ScrollMetrics = new ScrollMetrics(1,_field.numLines,_field.bottomScrollV-_field.scrollV);
				ret.value = _field.scrollV;
				return ret;
			}
			return null;
		}
		public function setScrollMetrics(direction:String,metrics:ScrollMetrics):void{
			if(direction==Direction.VERTICAL){
				_field.scrollV = metrics.value;
			}
		}
		public function getScrollMultiplier(direction:String):Number{
			return 1;
		}
	}
}