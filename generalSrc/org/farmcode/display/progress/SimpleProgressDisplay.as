package org.farmcode.display.progress
{
	import flash.display.BlendMode;
	import flash.display.CapsStyle;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.getTimer;

	/**
	 * TODO: add preloader props (e.g. progress,total,units, etc.) into their own 
	 * validation flag (seperate from positioning code).
	 */
	public class SimpleProgressDisplay extends AbstractProgressDisplay
	{
		private static const BAR_WIDTH:Number = 120;
		private static const BAR_HEIGHT:Number = 9;
		private static const DEFAULT_BACKGROUND_ALPHA:Number = 0.15;
		private static const TRANSITION_TIME:Number = 0.25; // in seconds
		
		public function get detailsFormat():String{
			return _detailsFormat;
		}
		public function set detailsFormat(value:String):void{
			if(_detailsFormat!=value){
				_detailsFormat = value;
				invalidate();
			}
		}
		
		public function get showMessage():Boolean{
			return _showMessage;
		}
		public function set showMessage(value:Boolean):void{
			if(_showMessage!=value){
				_showMessage = value;
				invalidate();
			}
		}
		
		public function get backgroundAlpha():Number{
			return _background.alpha;
		}
		public function set backgroundAlpha(value:Number):void{
			_background.alpha = value;
		}
		
		private var _showMessage:Boolean = false;
		private var _detailsFormat:String;
		
		private var _detailsField:TextField;
		private var _messageField:TextField;
		private var _container:Sprite;
		private var _centerContainer:Sprite;
		private var _background:Shape;
		private var _bar:Shape;
		private var _border:Shape;
		
		private var _transStart:Number;
		
		public function SimpleProgressDisplay(){
			init();
			super(new Sprite());
		}
		protected function init():void{
			var textFormat:TextFormat = new TextFormat("_sans",10.5,0);
			textFormat.align = TextFormatAlign.CENTER;
			
			_detailsField = new TextField();
			_detailsField.defaultTextFormat = textFormat;
			_detailsField.selectable = false;
			_detailsField.type = TextFieldType.DYNAMIC;
			
			_messageField = new TextField();
			_messageField.defaultTextFormat = textFormat;
			_messageField.selectable = false;
			_messageField.type = TextFieldType.DYNAMIC;
			
			_background = new Shape();
			_bar = new Shape();
			_border = new Shape();
			
			_centerContainer = new Sprite();
			_centerContainer.addChild(_bar);
			_centerContainer.addChild(_border);
			_centerContainer.addChild(_detailsField);
			_centerContainer.addChild(_messageField);
			
			_container = new Sprite();
			_container.alpha = 0;
			_container.blendMode = BlendMode.INVERT;
			_container.addChild(_background);
			_container.addChild(_centerContainer);
			
			_border.graphics.lineStyle(0,0,1,true,LineScaleMode.NONE,CapsStyle.SQUARE,JointStyle.MITER);
			_border.graphics.drawRect(0,0,BAR_WIDTH,BAR_HEIGHT);
			
			_background.graphics.beginFill(0,1);
			_background.graphics.drawRect(0,0,10,10);
			
			_bar.graphics.beginFill(0,1);
			_bar.graphics.drawRect(0,0,BAR_WIDTH,BAR_HEIGHT);
			
			backgroundAlpha = DEFAULT_BACKGROUND_ALPHA;
		}
		override protected function doShowIntro() : void{
			super.doShowIntro();
			clearTransitions();
			_transStart = getTimer();
			_container.addEventListener(Event.ENTER_FRAME, introTick);
		}
		protected function introTick(e:Event) : void{
			_container.alpha = (getTimer()-_transStart)/(TRANSITION_TIME*1000);
			if(_container.alpha>=1){
				clearTransitions();
			}
		}
		override protected function doShowOutro() : Number{
			var ret:Number = super.doShowOutro();
			clearTransitions();
			_transStart = getTimer();
			_container.addEventListener(Event.ENTER_FRAME, outroTick);
			if(ret<TRANSITION_TIME){
				return TRANSITION_TIME;
			}else{
				return ret;
			}
		}
		protected function outroTick(e:Event) : void{
			_container.alpha = 1-((getTimer()-_transStart)/(TRANSITION_TIME*1000));
			if(_container.alpha<=0){
				clearTransitions();
			}
		}
		protected function clearTransitions() : void{
			_container.removeEventListener(Event.ENTER_FRAME, introTick);
			_container.removeEventListener(Event.ENTER_FRAME, outroTick);
		}
		override protected function bindToAsset() : void{
			containerAsset.addChild(_container);
		}
		override protected function unbindFromAsset() : void{
			containerAsset.removeChild(_container);
		}
		override protected function measure() : void{
			
		}
		override protected function draw() : void{
			asset.x = displayPosition.x;
			asset.y = displayPosition.y;
			
			_background.width = displayPosition.width;
			_background.height = displayPosition.height;
			
			
			var width:Number = Math.min(displayPosition.width,BAR_WIDTH);
			
			if(_showMessage && message){
				_messageField.width = width;
				_messageField.text = message;
				_messageField.height = _messageField.textHeight+4;
				_messageField.y = -_messageField.height-BAR_HEIGHT/2
			}else{
				_messageField.text = "";
			}
			if(_detailsFormat && measurable){
				_detailsField.width = width;
				_detailsField.text = ProgressLabelFormatter.format(_detailsFormat,message,progress,total,units);
				_detailsField.height = _detailsField.textHeight+4;
				_detailsField.y = BAR_HEIGHT/2
			}else{
				_detailsField.text = "";
			}
			_bar.height = BAR_HEIGHT;
			_border.height = BAR_HEIGHT;
			_bar.width = width*(progress/total);
			_border.width = width;
			_bar.y = -BAR_HEIGHT/2;
			_border.y = -BAR_HEIGHT/2;
			
			_centerContainer.x = (displayPosition.width-width)/2;
			_centerContainer.y = displayPosition.height/2;
		}
	}
}