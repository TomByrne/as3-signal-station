package au.com.thefarmdigital.display.containerBinding
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	internal class DepthContainerBinding extends ContainerBinding
	{
		private var _depth: int;
	
		public function DepthContainerBinding(display: DisplayObject, depth: int = -1)
		{
			super(display);
			
			this._depth = depth;
		}
		
		public function get depth(): int
		{
			return this._depth;
		}
		public function set depth(value: int): void
		{
			if (value != this.depth)
			{
				this._depth = value;
				this.applyDepth();
			}
		}
		
		private function handleAdded(event: Event): void
		{
			this.setActive(true);
		}
		
		private function handleRemoved(event: Event): void
		{
			this.setActive(false);
		}
		
		private function setActive(active: Boolean): void
		{
			if (this.display.parent)
			{
				if (active)
				{
					this.display.parent.addEventListener(Event.ADDED, this.handleParentChange);
					this.display.parent.addEventListener(Event.REMOVED, this.handleParentChange);
					this.applyDepth();
				}
				else
				{
					this.display.parent.removeEventListener(Event.ADDED, this.handleParentChange);
					this.display.parent.removeEventListener(Event.REMOVED, this.handleParentChange);
				}
			}
		}
		
		private function handleParentChange(event: Event): void
		{
			this.applyDepth();
		}
		
		private function applyDepth(): void
		{
			if (this.display.parent && this.depth >= 0)
			{
				var currentIndex: int = this.display.parent.getChildIndex(this.display);
				var targetIndex: int = Math.min(this.depth, this.display.parent.numChildren - 1);
				if (currentIndex != targetIndex)
				{
					this.display.parent.setChildIndex(this.display, targetIndex);
				}
			}
		}
		
		override protected function preDisplayChange(newDisplay: DisplayObject): void
		{
			if (this.display != null)
			{
				this.display.removeEventListener(Event.ADDED_TO_STAGE, this.handleAdded);
				this.display.removeEventListener(Event.REMOVED_FROM_STAGE, this.handleRemoved);
			}
		}
		
		override protected function postDisplayChange(oldDisplay: DisplayObject): void
		{
			if (this.display != null)
			{
				this.display.addEventListener(Event.ADDED_TO_STAGE, this.handleAdded);
				this.display.addEventListener(Event.REMOVED_FROM_STAGE, this.handleRemoved);
			}
			this.setActive(true);
		}
	}
}