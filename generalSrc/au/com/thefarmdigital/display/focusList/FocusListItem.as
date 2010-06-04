package au.com.thefarmdigital.display.focusList
{
	import au.com.thefarmdigital.display.View;
	import au.com.thefarmdigital.tweening.LooseTween;
	
	import flash.utils.Dictionary;

	public class FocusListItem extends View
	{
		protected static const IMMEDIATE_FOCUS: uint = 0;
		protected static const VALID_FOCUS: uint = 1;
		protected static const PERFORM_FOCUS: uint = 2;		
		
		protected var data: *;
		protected var transitionTime: Number;
		protected var active: Boolean;
		protected var focusProperties: Array;		
		protected var focusValidStatus: uint;
		protected var focusDistance: uint;
		protected var itemValid: Boolean;
		private var focusTween:LooseTween;
		private var firstDraw: Boolean;
		private var xTween:LooseTween;
		
		public var easingFunction:Function;
		
		public function FocusListItem()
		{
			super();
			
			this.firstDraw = true;
			
			this.focusDistance = Number.MAX_VALUE;
			this.focusValidStatus = FocusListItem.VALID_FOCUS;
			
			this.focusProperties = new Array();
			
			this.itemValid = true;
			
			this.active = true;
			this.transitionTime = 0;
		}
		
		public function moveToX(x: Number): void
		{
			if (this.xTween != null)
			{
				this.xTween.stop();
			}
			xTween = new LooseTween(this, {x:x}, easingFunction, this.transitionTime);
			xTween.start()
		}
		
		public function getMaxWidth(): Number
		{
			return this.width;
		}
		
		public function isNew(): Boolean
		{
			return this.firstDraw;
		}
		
		public function getData(): *
		{
			return this.data;
		}
		
		public function setData(data: *): void
		{
			if (data == null)
			{
				throw new TypeError("Parameter data must be non-null");
			}
			else
			{
				this.data = data;
				this.invalidateItem();
			}
		}
		
		private function invalidateItem(): void
		{
			this.itemValid = false;
			this.validate(true);
		}
		
		public function setTransitionTime(transitionTime: Number): void
		{
			this.transitionTime = transitionTime;
		}
		
		override protected function draw(): void
		{	
			if (!this.itemValid)
			{
				this.drawItem();
				this.itemValid = true;
			}
				
			if (this.focusValidStatus == FocusListItem.IMMEDIATE_FOCUS || 
				this.focusValidStatus == FocusListItem.PERFORM_FOCUS)
			{
				this.drawFocus();
				this.focusValidStatus = FocusListItem.VALID_FOCUS;
			}
			
			this.firstDraw = false;
		}
		
		protected function drawItem(): void
		{
			
		}
		
		protected function drawFocus(): void
		{
			var index: uint = Math.min(this.focusDistance, this.focusProperties.length - 1);
			var focusProps: Dictionary = this.focusProperties[index] as Dictionary;
			
			if (focusProps != null)
			{
				if (this.focusTween != null)
				{
					this.focusTween.stop();
				}
					
				if (this.focusValidStatus == FocusListItem.IMMEDIATE_FOCUS)
				{
					for (var propName: String in focusProps)
					{
						var value: Number = focusProps[propName] as Number;
						this[propName] = value;
					} 
				}
				else
				{
					focusTween = new LooseTween(this, focusProps, easingFunction, transitionTime);
					focusTween.start();
				}
			}
		}
		
		/**
		 * Tweens the item to the relevant property values for its focus index
		 */
		public function setDistanceFromFocus(distance: uint, doNow: Boolean = false): void
		{
			this.focusDistance = distance;
			this.validateFocus(doNow);
		}
		
		private function validateFocus(immediate: Boolean): void
		{
			if (immediate)
			{
				this.focusValidStatus = FocusListItem.IMMEDIATE_FOCUS;
			}
			else
			{
				this.focusValidStatus = FocusListItem.PERFORM_FOCUS;
			}
			this.invalidate();
		}
		
		public function setFocusProperties(distance: uint, properties: Dictionary): void
		{
			this.focusProperties[distance] = properties;
		}
		
		private function isActive(): Boolean
		{
			return this.active;
		}
		
		/**
		 * Clears all resources and references
		 */
		public function dispose(force: Boolean = false): void
		{
			this.active = false;
			
			if (force)
			{
				if (this.focusTween != null)
				{
					this.focusTween.stop();
					this.focusTween = null; 
				}
				
				var event: FocusListItemEvent = new FocusListItemEvent(FocusListItemEvent.DISPOSED);
				this.dispatchEvent(event);
			}
			else
			{
				this.transitionOut();
			}
		}
		
		protected function transitionOut(): void
		{
			
		}
	}
}