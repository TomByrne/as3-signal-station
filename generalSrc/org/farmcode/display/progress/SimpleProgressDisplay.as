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
	
	import org.farmcode.display.assets.IContainerAsset;
	import org.farmcode.display.assets.IDisplayAsset;
	import org.farmcode.display.assets.IShapeAsset;
	import org.farmcode.display.assets.ISpriteAsset;
	import org.farmcode.display.assets.ITextFieldAsset;
	import org.farmcode.display.assets.nativeAssets.NativeAssetFactory;

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
		
		private var _detailsField:ITextFieldAsset;
		private var _messageField:ITextFieldAsset;
		private var _container:IContainerAsset;
		private var _centerContainer:IContainerAsset;
		private var _background:IShapeAsset;
		private var _bar:IShapeAsset;
		private var _border:IShapeAsset;
		
		public function SimpleProgressDisplay(){
			super(NativeAssetFactory.getNewByType(ISpriteAsset));
		}
		override protected function init():void{
			super.init();
			_textFormat = new TextFormat("_sans",10.5,0);
			_textFormat.align = TextFormatAlign.CENTER;
			backgroundAlpha = DEFAULT_BACKGROUND_ALPHA;
		}
		override protected function doShowIntro() : void{
			super.doShowIntro();
			clearTransitions();
			_transStart = getTimer();
			_container.enterFrame.addHandler(introTick);
		}
		protected function introTick(e:Event, from:IDisplayAsset) : void{
			_container.alpha = (getTimer()-_transStart)/(TRANSITION_TIME*1000);
			if(_container.alpha>=1){
				clearTransitions();
			}
		}
		override protected function doShowOutro() : Number{
			var ret:Number = super.doShowOutro();
			clearTransitions();
			_transStart = getTimer();
			_container.enterFrame.addHandler(outroTick);
			if(ret<TRANSITION_TIME){
				return TRANSITION_TIME;
			}else{
				return ret;
			}
		}
		protected function outroTick(e:Event, from:IDisplayAsset) : void{
			_container.alpha = 1-((getTimer()-_transStart)/(TRANSITION_TIME*1000));
			if(_container.alpha<=0){
				clearTransitions();
			}
		}
		protected function clearTransitions() : void{
			_container.enterFrame.removeHandler(introTick);
			_container.enterFrame.removeHandler(outroTick);
		}
		override protected function bindToAsset() : void{
			super.bindToAsset();
			_container = _containerAsset.createAsset(IContainerAsset);
			_container.alpha = 0;
			_container.blendMode = BlendMode.INVERT;
			
			_background = _container.createAsset(IShapeAsset);
			_background.graphics.beginFill(0,1);
			_background.graphics.drawRect(0,0,10,10);
			_background.alpha = _backgroundAlpha;
			_container.addAsset(_background);
			
			_centerContainer = _container.createAsset(IContainerAsset);
			_container.addAsset(_centerContainer);
			
			_detailsField = _containerAsset.createAsset(ITextFieldAsset);
			_detailsField.defaultTextFormat = _textFormat;
			_detailsField.selectable = false;
			_detailsField.type = TextFieldType.DYNAMIC;
			_centerContainer.addAsset(_detailsField);
			
			_messageField = _containerAsset.createAsset(ITextFieldAsset);
			_messageField.defaultTextFormat = _textFormat;
			_messageField.selectable = false;
			_messageField.type = TextFieldType.DYNAMIC;
			_centerContainer.addAsset(_messageField);
			
			_border = _containerAsset.createAsset(IShapeAsset);
			_border.graphics.lineStyle(0,0,1,true,LineScaleMode.NONE,CapsStyle.SQUARE,JointStyle.MITER);
			_border.graphics.drawRect(0,0,BAR_WIDTH,BAR_HEIGHT);
			_centerContainer.addAsset(_border);
			
			_bar = _containerAsset.createAsset(IShapeAsset);
			_bar.graphics.beginFill(0,1);
			_bar.graphics.drawRect(0,0,BAR_WIDTH,BAR_HEIGHT);
			_centerContainer.addAsset(_bar);
			
			_containerAsset.addAsset(_container);
		}
		override protected function unbindFromAsset() : void{
			_containerAsset.destroyAsset(_container);
			_containerAsset.removeAsset(_container);
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