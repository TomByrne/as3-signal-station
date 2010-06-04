package au.com.thefarmdigital.display.carousel {
	
	import au.com.thefarmdigital.display.View;
	import au.com.thefarmdigital.tweening.LooseTween;
	
	import flash.display.*;
	import flash.events.*;
	import flash.filters.BlurFilter;
	
	import org.goasap.events.GoEvent;
    
    /**
    * This is dispatched when a carousel item is clicked (and the spinning transition begins).
    * 
    * @eventType au.com.thefarmdigital.display.carousel.CarouselEvent.ITEM_CLICKED
    */
	[Event(name="itemClicked",type="au.com.thefarmdigital.display.carousel.CarouselEvent")]
    /**
    * This is dispatched when the spinning transition is not running and the user clicks on the focused item.
    * 
    * @eventType au.com.thefarmdigital.display.carousel.CarouselEvent.FOCUSED_ITEM_CLICKED
    */
	[Event(name="focusedItemClicked",type="au.com.thefarmdigital.display.carousel.CarouselEvent")]
    /**
    * This is dispatched when the mouse rolls over a carousel item.
    * 
    * @eventType au.com.thefarmdigital.display.carousel.CarouselEvent.ITEM_OVER
    */
	[Event(name="itemOver",type="au.com.thefarmdigital.display.carousel.CarouselEvent")]
    /**
    * This is dispatched when the mouse rolls off a carousel item.
    * 
    * @eventType au.com.thefarmdigital.display.carousel.CarouselEvent.ITEM_OUT
    */
	[Event(name="itemOut",type="au.com.thefarmdigital.display.carousel.CarouselEvent")]
    /**
    * This is dispatched when the spinning transition finishes.
    * 
    * @eventType au.com.thefarmdigital.display.carousel.CarouselEvent.MOTION_FINISHED
    */
	[Event(name="motionFinished",type="au.com.thefarmdigital.display.carousel.CarouselEvent")]
	/**
	 * The Carousel class displays 2D items in a carousel arrangement (scaling items to give the appearance of depth).
	 * It has the option of applying a blur to the items when the carousel moves.
	 */
	public class Carousel extends View {
		public function set rangeX(to:Number):void {
			if (_xrange != to && !isNaN(to)) {
				_xrange = to;
				invalidate();
			}
		}
		public function get rangeX():Number {
			return _xrange;
		}	

		public function set rangeY(to:Number):void {
			if (_yrange != to && !isNaN(to)) {
				_yrange = to;
				invalidate();
			}
		}
		public function get rangeY():Number {
			return _yrange;
		}	
		
		public function set centerX(to:Number):void {
			if (_xcenter != to && !isNaN(to)) {
				_xcenter = to;
			}
		}
		public function get centerX():Number {
			return _xcenter;
		}	
		
		public function set centerY(to:Number):void {
			if (_ycenter != to && !isNaN(to)) {
				_ycenter = to;
			}
		}
		public function get centerY():Number {
			return _ycenter;
		}			
		
		public function set rangeScale(to:Number):void {
			if (rangeScale != to && !isNaN(to)) {
				_rangeScale = to;
				invalidate();
			}
		}
		public function get rangeScale():Number {
			return _rangeScale;
		}			

		/**
		 * The dataProvider property should be an array of objects which implement ICarouselItem.
		 */
		public function set dataProvider(to:Array):void {
			if (_dataProvider != to) {
				clearChildren();
				_dataProvider = to;
				createChildren();
				invalidate();
			}			
		}
		public function get dataProvider():Array{
			return _dataProvider;
		}
		public function set itemIndex (to:Number):void {
			_itemIndex = to;
			tweenTo(_itemIndex);
		}
		public function get itemIndex ():Number {
			return _itemIndex;
		}
		public function set blurMultiplier(to:Number):void {
			if (_blurMultiplier != to && !isNaN(to)) {
				_blurMultiplier = to;
			}
		}
		public function get blurMultiplier():Number {
			return _blurMultiplier;
		}
		
		public function set enabled(to:Boolean):void {
			if (to != _enabled) {
				_enabled = to;
				var length:int =  _dataProvider.length;
				for(var i:int = 0; i<length; ++i) {
					if (_enabled) _dataProvider[i].display.addEventListener(MouseEvent.CLICK, itemClickHandler);
					else _dataProvider[i].display.removeEventListener(MouseEvent.CLICK, itemClickHandler);
					_dataProvider[i].display.buttonMode = to;
				}
			}
		}
		public function get enabled():Boolean {
			return _enabled;
		}
		

		
		private var _xrange				:Number;
		private var _yrange				:Number;
		private var _rangeScale			:Number;
		private var _dataProvider		:Array = [];
		private var _rotation			:Number = 0;
		private var _xcenter			:Number;
		private var _ycenter			:Number		
		private var _items				:Array = [];
		private var _itemIndex			:Number = 0;		
		private var _tween				:LooseTween;
		private var _blurMultiplier		:Number = 0;
		private var _enabled			:Boolean = true;
		private var _tweenFinish		:Boolean = true;
		
		/**
		 * The easing function to be used when the carousel spins
		 */
		public var transitionEasing		:Function;
		/**
		 * <p>The duration (in seconds) of the carousel's spinning transition.</p>
		 * <p>If scaleTransitionDuration is set to true, transitionDuration is in seconds per one hundred degrees.</p>
		 */
		public var transitionDuration		:Number = 1;
		/**
		 * <p>When scaleTransitionDuration is set to true, the duration of a transition is worked out as:</p>
		 * <p>duration = ((amount of degrees)/100)*transitionDuration</p>
		 */
		public var scaleTransitionDuration	:Boolean = false;
		
		
		public function Carousel()
		{
			super();
			
			// Set default values if they haven't been set yet
			// TODO: More intelligent, taking in to account bounds instwead of width etc
			if (isNaN(this._rangeScale))
			{
				this._rangeScale = 0;
			}
			if (isNaN(this._xrange))
			{
				this._xrange = this.width;
			}
			if (isNaN(this._yrange))
			{
				this._yrange = this.height;
			}
			if (isNaN(this._xcenter))
			{
				this._xcenter = this._xrange / 2;
			}
			if (isNaN(this._ycenter))
			{
				this._ycenter = this._yrange / 2;
			}
		}
		
		private function createChildren():void{
			var length:int =  _dataProvider.length;
			for(var i:int = 0; i<length; ++i){
				var data:ICarouselItem = _dataProvider[i];
				var display:DisplayObject = data.display;
				addChild(display);
			}
		}
		
		private function clearChildren():void{
			if(_dataProvider){
				var length:int =  _dataProvider.length;
				for(var i:Number = 0; i<length; ++i){
					var display:DisplayObject = (_dataProvider[i]as ICarouselItem).display;
					removeChild(display);
				}
			}
			_items = [];
		}
		
		override protected function draw():void {
			
			var assumedOffset:Number = (360/_dataProvider.length);		// Fix assumed offset <- hard coded spacing
			
			var length:int =  _dataProvider.length;
			for(var i:int = 0; i<length; ++i){
				var data:ICarouselItem = _dataProvider[i];
				var display:DisplayObject = data.display;
				var angle:Number = data.angleOffset;
				if(isNaN(angle))angle = assumedOffset*i;
				var radians:Number = (angle+_rotation)*(Math.PI/180);
				
				display.addEventListener(MouseEvent.CLICK, itemClickHandler);
				display.addEventListener(MouseEvent.MOUSE_OVER, itemMouseOverHandler);
				display.addEventListener(MouseEvent.MOUSE_OUT, itemMouseOutHandler);

				display.x = Math.round( _xcenter+(Math.sin(radians)*_xrange));
				display.y = Math.round(_ycenter+(Math.cos(radians)*_yrange));				
				display.scaleX = display.scaleY = (1-_rangeScale)+(Math.cos(radians)*(_rangeScale));
			}
			// Should be on display's y property
			var sorted:Array = _dataProvider.sort(this.sortByDisplayY,Array.NUMERIC|Array.RETURNINDEXEDARRAY);
			i = sorted.length;
			while(i--){
				data = _dataProvider[sorted[i]];
				if (getChildAt(i) != data.display) {
					setChildIndex(data.display, i);
				}
			}
		}
		
		private function sortByDisplayY(item1: ICarouselItem, item2: ICarouselItem): int
		{
			var diff: int = 0;
			
			if (item1.display.y > item2.display.y)
			{
				diff = 1;
			}
			else if (item1.display.y < item2.display.y)
			{
				diff = -1;
			}
			
			return diff;
		}
		
		private function tweenTo(index:Number):void {

			index = index % _dataProvider.length;
			if(index<0) index +=_dataProvider.length;
			
			var angle:Number = Math.round(360-((360/_dataProvider.length)*index));				
			
			var duration:Number = (scaleTransitionDuration?(Math.abs(_rotation-angle)/100)*transitionDuration:transitionDuration);
			
			if(_rotation>180) _rotation -= 360;
			else if(_rotation<-180) _rotation += 360;
			if(_rotation-angle>180) angle += 360;
			else if(_rotation-angle<-180) angle -= 360			
			
			var proxy:Object = {previousAngle:_rotation}

			if (_tween != null) _tween.stop();
			_tween = new LooseTween(proxy,{rotation:angle}, transitionEasing, duration);
			_tween.addEventListener(GoEvent.UPDATE,onMotionHandler);
			_tween.addEventListener(GoEvent.COMPLETE,onMotionFinish);
			_tween.start();
			
			_tweenFinish = false;
			_itemIndex = index;
		}	
		private function onMotionHandler(tweenEvent:GoEvent):void {
			_rotation = tweenEvent.target.obj.rotation;
			var blur:Number = Math.abs((_rotation-tweenEvent.target.obj.previousAngle)*_blurMultiplier);
			tweenEvent.target.obj.previousAngle = _rotation;
			if(blur){
				filters = [new BlurFilter(blur, 0, 1)];
			}else{
				filters = [];
			}
			validate(true);
		}	
		private function onMotionFinish(tweenEvent:GoEvent):void 
		{
			filters = [];
			var carouselEvent:CarouselEvent;
			_tweenFinish = true;
			carouselEvent = new CarouselEvent(CarouselEvent.MOTION_FINISHED);
			carouselEvent.targetItem = _dataProvider[_itemIndex];
			carouselEvent.targetIndex = _itemIndex;			
			dispatchEvent(carouselEvent);	
		}					
		
		private function itemClickHandler(event:MouseEvent):void 
		{		
			var index:Number = findIndex(event.currentTarget as InteractiveObject);			
			var carouselEvent:CarouselEvent;
			
			if (index == _itemIndex) {
				if (_tweenFinish) {				
					carouselEvent = new CarouselEvent(CarouselEvent.FOCUSED_ITEM_CLICKED);
					carouselEvent.targetItem = _dataProvider[index];
					carouselEvent.targetIndex = index;			
					dispatchEvent(carouselEvent);
				}
			} else {
				tweenTo(index);				
				carouselEvent = new CarouselEvent(CarouselEvent.ITEM_CLICKED);
				carouselEvent.targetItem = _dataProvider[index];
				carouselEvent.targetIndex = index;				
				dispatchEvent(carouselEvent);				
			}
		}
		
		private function itemMouseOverHandler(event:MouseEvent):void 
		{
			var index:Number = findIndex(event.target as InteractiveObject);			
			var carouselEvent:CarouselEvent = new CarouselEvent(CarouselEvent.ITEM_OVER);
				carouselEvent.targetItem = _dataProvider[index];
				carouselEvent.targetIndex = index;			
			dispatchEvent(carouselEvent);			
		}
		
		private function itemMouseOutHandler(event:MouseEvent):void 
		{
			var index:Number = findIndex(event.target as InteractiveObject);
			
			var carouselEvent:CarouselEvent = new CarouselEvent(CarouselEvent.ITEM_OUT);
				carouselEvent.targetItem = _dataProvider[index];
				carouselEvent.targetIndex = index;			
			dispatchEvent(carouselEvent);			
		}
			
		
		private function findIndex(child:InteractiveObject):int {
			var length:int = _dataProvider.length;
			for(var i:int=0; i<length; ++i) {
				if(_dataProvider[i].display==child) return i;
			}
			return -1;
		}
	}
}