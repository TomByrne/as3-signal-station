package au.com.thefarmdigital.display.carousel
{
	import flash.events.Event;

	public class CarouselEvent extends Event
	{
		public static var ITEM_CLICKED			:String = "itemClicked";
		public static var FOCUSED_ITEM_CLICKED	:String = "focusedItemFocused";
		public static var ITEM_OVER				:String = "itemOver";
		public static var ITEM_OUT				:String = "itemOut";
		public static var MOTION_FINISHED		:String = "motionFinished";
		

		public function set targetItem(to:ICarouselItem):void 
		{
			_targetitem = to;
		}
		public function get targetItem():ICarouselItem 
		{
			return _targetitem;
		}		
		
		public function set targetIndex(to:Number):void 
		{
			_targetindex = to;
		}
		public function get targetIndex():Number 
		{
			return _targetindex;
		}		
		
		private var _targetitem	:ICarouselItem;
		private var _targetindex:Number;
		
		public function CarouselEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type,bubbles,cancelable);
		}
		
		override public function clone():Event
		{
			var copy: CarouselEvent = new CarouselEvent(this.type, this.bubbles, this.cancelable);
			copy.targetIndex = this.targetIndex;
			copy.targetItem = this.targetItem;
			
			return copy;
		}
	}
}