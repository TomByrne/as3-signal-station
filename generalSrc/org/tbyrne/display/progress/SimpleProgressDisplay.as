package org.tbyrne.display.progress
{
	import flash.display.*;
	import flash.events.Event;
	import flash.text.*;
	import flash.utils.getTimer;
	
	import org.tbyrne.core.EnterFrameHook;
	import org.tbyrne.display.assets.nativeAssets.NativeAssetFactory;
	import org.tbyrne.display.assets.nativeAssets.SpriteAsset;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;

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
		private static const NON_MEAS_CYCLE:Number = 1; // in seconds
		private static const NON_MEAS_WIDTH:Number = 0.2; // as fract
		
		public function get detailsFormat():String{
			return _detailsFormat;
		}
		public function set detailsFormat(value:String):void{
			if(_detailsFormat!=value){
				_detailsFormat = value;
				invalidateSize();
			}
		}
		
		public function get showMessage():Boolean{
			return _showMessage;
		}
		public function set showMessage(value:Boolean):void{
			if(_showMessage!=value){
				_showMessage = value;
				invalidateSize();
			}
		}
		
		public function get backgroundAlpha():Number{
			return _backgroundAlpha;
		}
		public function set backgroundAlpha(value:Number):void{
			_backgroundAlpha = value;
			if(_background)_background.alpha = _backgroundAlpha;
		}
		
		public function get textColour():Number{
			return _textColour;
		}
		public function set textColour(value:Number):void{
			_textColour = value;
			if(_inited){
				_detailsField.textColor = _textColour;
				_messageField.textColor = _textColour;
			}
		}
		public function get foregroundColour():Number{
			return _foregroundColour;
		}
		public function set foregroundColour(value:Number):void{
			_foregroundColour = value;
			if(_inited)drawForeground();
		}
		public function get backgroundColour():Number{
			return _backgroundColour;
		}
		public function set backgroundColour(value:Number):void{
			_backgroundColour = value;
			if(_inited)drawBackground();
		}
		
		public function get doInvertBlend():Boolean{
			return _doInvertBlend;
		}
		public function set doInvertBlend(value:Boolean):void{
			_doInvertBlend = value;
			if(_container)_container.blendMode = value?BlendMode.INVERT:BlendMode.NORMAL;
		}
		
		public var transitionTime:Number = TRANSITION_TIME;
		
		private var _doInvertBlend:Boolean = true;
		private var _foregroundColour:Number = 0;
		private var _textColour:Number = 0;
		private var _backgroundColour:Number = 0;
		private var _backgroundAlpha:Number;
		private var _showMessage:Boolean = false;
		private var _detailsFormat:String;
		private var _textFormat:TextFormat;
		private var _transStartTime:Number;
		private var _transStartValue:Number;
		
		private var _containerWrapper:SpriteAsset;
		private var _detailsField:TextField;
		private var _messageField:TextField;
		private var _container:Sprite;
		private var _centerContainer:Sprite;
		private var _background:Shape;
		private var _bar:Shape;
		private var _border:Shape;
		
		private var _transInRunning:Boolean;
		private var _transOutRunning:Boolean;
		
		public function SimpleProgressDisplay(asset:IDisplayObject=null){
			super(asset);
			backgroundAlpha = DEFAULT_BACKGROUND_ALPHA;
		}
		override protected function init():void{
			super.init();
			_textFormat = new TextFormat("_sans",10.5,0);
			_textFormat.align = TextFormatAlign.CENTER;
			
			_container = new Sprite();
			_container.alpha = (_active.booleanValue?1:0);
			_container.blendMode = _doInvertBlend?BlendMode.INVERT:BlendMode.NORMAL;
			
			_background = new Shape();
			drawBackground();
			_background.alpha = _backgroundAlpha;
			_container.addChild(_background);
			
			_centerContainer = new Sprite();
			_container.addChild(_centerContainer);
			
			_detailsField = new TextField();
			_detailsField.defaultTextFormat = _textFormat;
			_detailsField.selectable = false;
			_detailsField.type = TextFieldType.DYNAMIC;
			_detailsField.textColor = _textColour;
			_centerContainer.addChild(_detailsField);
			
			_messageField = new TextField();
			_messageField.defaultTextFormat = _textFormat;
			_messageField.selectable = false;
			_messageField.type = TextFieldType.DYNAMIC;
			_messageField.textColor = _textColour;
			_centerContainer.addChild(_messageField);
			
			_border = new Shape();
			_bar = new Shape();
			drawForeground();
			_centerContainer.addChild(_border);
			_centerContainer.addChild(_bar);
			
		}
		protected function drawBackground() : void{
			_background.graphics.clear();
			_background.graphics.beginFill(_backgroundColour,1);
			_background.graphics.drawRect(0,0,10,10);
		}
		protected function drawForeground() : void{
			_border.graphics.clear();
			_border.graphics.lineStyle(0,_foregroundColour,1,true,LineScaleMode.NONE,CapsStyle.SQUARE,JointStyle.MITER);
			_border.graphics.drawRect(0,0,BAR_WIDTH,BAR_HEIGHT);
			
			_bar.graphics.clear();
			_bar.graphics.beginFill(_foregroundColour,1);
			_bar.graphics.drawRect(0,0,BAR_WIDTH,BAR_HEIGHT);
			invalidateSize();
		}
		override protected function doShowIntro() : void{
			super.doShowIntro();
			startTransIn();
		}
		protected function startTransIn() : void{
			if(transitionTime>0 && _container.alpha<1){
				clearTransitions();
				_transStartValue = _container.alpha;
				_transStartTime = getTimer();
				_transInRunning = true;
				_container.addEventListener(Event.ENTER_FRAME, introTick);
			}else{
				_container.alpha = 1;
			}
		}
		protected function introTick(e:Event) : void{
			_container.alpha = _transStartValue+(getTimer()-_transStartTime)/(transitionTime*1000);
			if(_container.alpha>=1){
				clearTransitions();
			}
		}
		override protected function doShowOutro() : Number{
			var ret:Number = super.doShowOutro();
			startTransOut();
			var duration:Number = _container.alpha*transitionTime;
			if(ret<duration){
				return duration;
			}else{
				return ret;
			}
		}
		protected function startTransOut() : void{
			if(transitionTime>0){
				clearTransitions();
				_transStartValue = _container.alpha;
				_transStartTime = getTimer();
				_transOutRunning = true;
				_container.addEventListener(Event.ENTER_FRAME, outroTick);
			}else{
				_container.alpha = 0;
			}
		}
		protected function outroTick(e:Event) : void{
			_container.alpha = _transStartValue-((getTimer()-_transStartTime)/(transitionTime*1000));
			if(_container.alpha<=0){
				clearTransitions();
			}
		}
		protected function clearTransitions() : void{
			_transInRunning = false;
			_transOutRunning = false;
			_container.removeEventListener(Event.ENTER_FRAME, introTick);
			_container.removeEventListener(Event.ENTER_FRAME, outroTick);
		}
		override protected function bindToAsset() : void{
			super.bindToAsset();
			if(!_containerWrapper){
				var factory:NativeAssetFactory = _containerAsset.factory as NativeAssetFactory;
				if(!factory){
					factory = new NativeAssetFactory();
				}
				_containerWrapper = factory.getNew(_container);
			}
			_containerAsset.addAsset(_containerWrapper);
		}
		override protected function unbindFromAsset() : void{
			_containerAsset.removeAsset(_containerWrapper);
			super.unbindFromAsset();
		}
		override protected function measure() : void{
			// ignore
		}
		protected function get shouldShow() : Boolean{
			return (_active.booleanValue);
		}
		override protected function commitProgress():void{
			validateSize(true);
		}
		override protected function commitSize():void{
			var isMeas:Boolean = (_measurable.booleanValue && !isNaN(_progress.numericalValue) && !isNaN(_total.numericalValue));
			
			
			_background.width = position.x;
			_background.height = position.y;
			
			var width:Number = Math.min(size.x,BAR_WIDTH);
			var shouldShow:Boolean = this.shouldShow;
			if(shouldShow){
				if(_container.alpha<1 && !_transInRunning){
					startTransIn();
				}
			}else if(_container.alpha>0 && !_transOutRunning){
				startTransOut();
			}
			
			if(_showMessage && _message.stringValue){
				_messageField.width = width;
				_messageField.text = _message.stringValue;
				_messageField.height = _messageField.textHeight+4;
				_messageField.y = -_messageField.height-BAR_HEIGHT/2
			}else{
				_messageField.text = "";
			}
			if(_detailsFormat && isMeas){
				_detailsField.width = width;
				_detailsField.text = ProgressLabelFormatter.format(_detailsFormat,_message.stringValue,_progress.numericalValue,_total.numericalValue,_units.stringValue);
				_detailsField.height = _detailsField.textHeight+4;
				_detailsField.y = BAR_HEIGHT/2
			}else{
				_detailsField.text = "";
			}
			_bar.height = BAR_HEIGHT;
			_border.height = BAR_HEIGHT;
			_border.width = width;
			_bar.y = -BAR_HEIGHT/2;
			_border.y = -BAR_HEIGHT/2;
			
			
			if(!isMeas){
				EnterFrameHook.getAct().addHandler(onEnterFrame);
				commitBarWidth();
			}else{
				EnterFrameHook.getAct().removeHandler(onEnterFrame);
				_bar.width = shouldShow?(width*(progress.numericalValue/total.numericalValue)):width;
				_bar.x = 0;
			}
			
			_centerContainer.x = (_size.x-width)/2;
			_centerContainer.y = _size.y/2;
		}
		
		private function onEnterFrame():void{
			commitBarWidth();
		}
		
		
		private function commitBarWidth():void{
			var width:Number = Math.min(size.x,BAR_WIDTH);
			var fract:Number = (getTimer()%(NON_MEAS_CYCLE*1000))/(NON_MEAS_CYCLE*1000);
			var barWidth:Number = width*NON_MEAS_WIDTH;
			var x:Number = fract*(width+barWidth)-barWidth;
			_bar.x = Math.max(x,0);
			_bar.width = Math.min(barWidth-(_bar.x-x),width-_bar.x);
		}
		
	}
}