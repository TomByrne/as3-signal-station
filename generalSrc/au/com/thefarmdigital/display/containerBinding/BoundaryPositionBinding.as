package au.com.thefarmdigital.display.containerBinding
{
	import flash.display.StageAlign;
	import flash.events.Event;

	public class BoundaryPositionBinding extends ContainerBinding
	{
		private var _resizeEvent: String;
		
		public function BoundaryPositionBinding()
		{
			this.resizeEvent = Event.RESIZE;
		}
		
		public function get resizeEvent(): String
		{
			return this._resizeEvent;
		}
		public function set resizeEvent(value: String): void
		{
			if (value != this.resizeEvent)
			{
				this._resizeEvent = value;
			}
		}
		
		protected function updateListening(): void
		{
			// TODO:
		}
	}
}