package org.tbyrne.display.controls
{
	import fl.transitions.easing.Regular;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.goasap.events.GoEvent;
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.actInfo.IMouseActInfo;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
	import org.tbyrne.display.assets.nativeTypes.IInteractiveObject;
	import org.tbyrne.display.constants.Anchor;
	import org.tbyrne.display.constants.Direction;
	import org.tbyrne.tweening.LooseTween;
	
	/**
	 * This class is generally aimed at mute/unmute buttons, which have a volume Slider
	 * that appears when the user rolls over the button.
	 */
	public class SliderButton extends ToggleButton
	{
		private static const SLIDER_ASSET:String = "slider";
		
		// this distance allows the slider to have effects which fall outside of it's bounds
		private static const MASK_PADDING:Number = 15;
		// the amount of time in seconds after the mouse rolls out, before it begins to get hidden.
		private static const HIDE_DELAY:Number = 0.4;
		// the amount of time in seconds it takes the slider to move in or out.
		private static const TRANS_DURATION:Number = 0.25;
		
		
		public function get value():Number{
			return _slider.value;
		}
		public function set value(value:Number):void{
			_slider.value = value;
		}
		override public function set active(value:Boolean):void{
			_slider.active = value;
			super.active = value;
		}
		public function get sliderAnchor():String{
			return _sliderAnchor?_sliderAnchor:_assumedAnchor;
		}
		public function set sliderAnchor(value:String):void{
			if(_sliderAnchor!=value){
				_sliderAnchor = value;
				
				var newAnch:String = sliderAnchor;
				if(newAnch==Anchor.TOP || newAnch==Anchor.BOTTOM){
					_slider.direction = Direction.VERTICAL;
				}else if(newAnch==Anchor.LEFT || newAnch==Anchor.RIGHT){
					_slider.direction = Direction.HORIZONTAL;
				}else{
					Log.error( "SliderButton.sliderAnchor: Invalid anchor, must be top, bottom, left or right");
				}
				invalidateSize();
			}
		}
		
		/**
		 * handler(from:Slider, value:Number)
		 */
		public function get valueChanged():IAct{
			if(!_valueChange)_valueChange = new Act();
			return _valueChange;
		}
		/**
		 * handler(from:Slider, value:Number)
		 */
		public function get valueChangedByUser():IAct{
			if(!_valueChangeByUser)_valueChangeByUser = new Act();
			return _valueChangeByUser;
		}
		
		private var _valueChangeByUser:Act;
		private var _valueChange:Act;
		
		private var _tweenRunning:Boolean;
		private var _openTween:LooseTween;
		private var _sliderAnchor:String;
		private var _slider:Slider;
		private var _sliderAsset:IDisplayObject;
		private var _openFract:Number = 0;
		private var _assumedAnchor:String;
		private var _scrollRect:Rectangle;
		private var _mouseOver:Boolean;
		
		public function SliderButton(asset:IDisplayObject=null){
			super(asset);
		}
		override protected function init():void{
			super.init();
			_slider = new Slider();
			_slider.measurementsChanged.addHandler(onSliderMeasChanged);
			_slider.valueChanged.addHandler(onValueChanged);
			_slider.valueChangedByUser.addHandler(onValueChangedByUser);
			_scrollRect = new Rectangle();
		}
		protected function onValueChanged(from:Slider, value:Number):void{
			if(_valueChange)_valueChange.perform(this,value);
		}
		protected function onValueChangedByUser(from:Slider, value:Number):void{
			if(_valueChangeByUser)_valueChangeByUser.perform(this,value);
		}
		protected function onSliderMeasChanged(from:Slider, oldW:Number, oldH:Number):void{
			invalidateSize();
		}
		override protected function bindToAsset() : void{
			super.bindToAsset();
			_sliderAsset = _containerAsset.takeAssetByName(SLIDER_ASSET,true);
			if(_sliderAsset){
				_interactiveObjectAsset.mousedOver.addHandler(onMousedOver);
				_interactiveObjectAsset.mousedOut.addHandler(onMousedOut);
				
				_slider.setAssetAndPosition(_sliderAsset);
				if(_slider.direction==Direction.VERTICAL){
					if(-_slider.asset.y>_slider.asset.y+_slider.asset.naturalHeight){
						_assumedAnchor = Anchor.TOP;
					}else{
						_assumedAnchor = Anchor.BOTTOM;
					}
				}else{
					if(-_slider.asset.x>_slider.asset.x+_slider.asset.naturalWidth){
						_assumedAnchor = Anchor.LEFT;
					}else{
						_assumedAnchor = Anchor.RIGHT;
					}
				}
			}
		}
		override protected function unbindFromAsset() : void{
			super.unbindFromAsset();
			if(_sliderAsset){
				_interactiveObjectAsset.mousedOver.removeHandler(onMousedOver);
				_interactiveObjectAsset.mousedOut.removeHandler(onMousedOut);
				
				_slider.asset = null;
				_containerAsset.returnAsset(_sliderAsset);
				_sliderAsset = null;
			}
		}
		override protected function commitSize():void{
			super.commitSize();
			if(_sliderAsset){
				updateMask();
			}
		}
		protected function updateMask():void{
			var anch:String = sliderAnchor;
			var slidMeas:Point = _slider.measurements;
			var meas:Point = measurements;
			var sliderX:Number;
			var sliderY:Number;
			
			if(_slider.direction==Direction.VERTICAL){
				_scrollRect.x = -MASK_PADDING;
				_scrollRect.height = (slidMeas.y*_openFract)+MASK_PADDING;
				_scrollRect.width = slidMeas.x+MASK_PADDING*2;
				sliderX = -MASK_PADDING;
				if(anch==Anchor.TOP){
					sliderY = -(slidMeas.y*_openFract)-MASK_PADDING;
					_scrollRect.y = -MASK_PADDING;
				}else if(anch==Anchor.BOTTOM){
					sliderY = meas.y;
					_scrollRect.y = slidMeas.y*(1-_openFract);
				}
			}else{
				_scrollRect.y = -MASK_PADDING;
				_scrollRect.width = (slidMeas.x*_openFract)+MASK_PADDING;
				_scrollRect.height = slidMeas.y+MASK_PADDING*2;
				sliderY = -MASK_PADDING;
				if(anch==Anchor.LEFT){
					sliderX = -(slidMeas.x*_openFract)-MASK_PADDING;
					_scrollRect.x = -MASK_PADDING;
				}else if(anch==Anchor.RIGHT){
					sliderX = meas.x;
					_scrollRect.x = slidMeas.x*(1-_openFract);
				}
			}
			_slider.setPosition(sliderX,sliderY);
			_slider.setSize(slidMeas.x,slidMeas.y);
			_slider.asset.scrollRect = _scrollRect;
		}
		
		protected function onMousedOver(from:IInteractiveObject, mouseActInfo:IMouseActInfo) : void{
			if(_active){
				transTo(1);
				_mouseOver = true;
			}
		}
		protected function onMousedOut(from:IInteractiveObject, mouseActInfo:IMouseActInfo) : void{
			transTo(0,HIDE_DELAY);
			_mouseOver = false;
		}
		protected function transTo(value:Number, delay:Number=0) : void{
			if((!_tweenRunning && value!=_openFract) || (_tweenRunning && _openTween.destProps.value!=value)){
				_tweenRunning = true;
				if(_openTween){
					_openTween.stop();
				}else{
					_openTween = new LooseTween({value:_openFract},null,null,TRANS_DURATION);
					_openTween.addEventListener(GoEvent.UPDATE,onUpdate);
					_openTween.addEventListener(GoEvent.COMPLETE,onComplete);
				}
				var easing:Function = (value==0?Regular.easeIn:(_openFract==0?Regular.easeOut:Regular.easeInOut));
				_openTween.delay = delay;
				_openTween.easing = easing;
				_openTween.destProps = {value:value};
				_openTween.start();
			}else if(value!=_openFract){
				invalidateSize();
				if(_openFract && !_mouseOver && !_tweenRunning){
					transTo(0,HIDE_DELAY);
				}
			}
		}
		protected function onUpdate(e:GoEvent) : void{
			_openFract = _openTween.target.value;
			validate(true);
		}
		protected function onComplete(e:GoEvent) : void{
			_tweenRunning = false;
			if(_openFract && !_mouseOver){
				transTo(0,HIDE_DELAY);
			}
		}
	}
}