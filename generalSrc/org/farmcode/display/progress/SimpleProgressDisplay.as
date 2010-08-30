package org.farmcode.display.progress
{
	import flash.display.*;
	import flash.events.Event;
	import flash.text.*;
	import flash.utils.getTimer;
	
	import org.farmcode.display.assets.assetTypes.IDisplayAsset;
	import org.farmcode.display.assets.nativeAssets.NativeAssetFactory;
	import org.farmcode.display.assets.nativeAssets.SpriteAsset;

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
			return _backgroundAlpha;
		}
		public function set backgroundAlpha(value:Number):void{
			_backgroundAlpha = value;
			if(_background)_background.alpha = _backgroundAlpha;
		}
		
		private var _backgroundAlpha:Number;
		private var _showMessage:Boolean = false;
		private var _detailsFormat:String;
		private var _textFormat:TextFormat;
		private var _transStart:Number;
		
		private var _containerWrapper:SpriteAsset;
		private var _detailsField:TextField;
		private var _messageField:TextField;
		private var _container:Sprite;
		private var _centerContainer:Sprite;
		private var _background:Shape;
		private var _bar:Shape;
		private var _border:Shape;
		
		public function SimpleProgressDisplay(asset:IDisplayAsset){
			super(asset);
		}
		override protected function init():void{
			super.init();
			_textFormat = new TextFormat("_sans",10.5,0);
			_textFormat.align = TextFormatAlign.CENTER;
			backgroundAlpha = DEFAULT_BACKGROUND_ALPHA;
			
			_container = new Sprite();
			_container.alpha = 0;
			_container.blendMode = BlendMode.INVERT;
			
			_background = new Shape();
			_background.graphics.beginFill(0,1);
			_background.graphics.drawRect(0,0,10,10);
			_background.alpha = _backgroundAlpha;
			_container.addChild(_background);
			
			_centerContainer = new Sprite();
			_container.addChild(_centerContainer);
			
			_detailsField = new TextField();
			_detailsField.defaultTextFormat = _textFormat;
			_detailsField.selectable = false;
			_detailsField.type = TextFieldType.DYNAMIC;
			_centerContainer.addChild(_detailsField);
			
			_messageField = new TextField();
			_messageField.defaultTextFormat = _textFormat;
			_messageField.selectable = false;
			_messageField.type = TextFieldType.DYNAMIC;
			_centerContainer.addChild(_messageField);
			
			_border = new Shape();
			_border.graphics.lineStyle(0,0,1,true,LineScaleMode.NONE,CapsStyle.SQUARE,JointStyle.MITER);
			_border.graphics.drawRect(0,0,BAR_WIDTH,BAR_HEIGHT);
			_centerContainer.addChild(_border);
			
			_bar = new Shape();
			_bar.graphics.beginFill(0,1);
			_bar.graphics.drawRect(0,0,BAR_WIDTH,BAR_HEIGHT);
			_centerContainer.addChild(_bar);
			
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
			_container.removeEventListener(Event.ENTER_FRAME, outroTick);
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
			
		}
		override protected function draw() : void{
			positionAsset();
			
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