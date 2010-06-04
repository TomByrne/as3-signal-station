package au.com.thefarmdigital.display.containerBinding
{
	import flash.display.DisplayObject;

	public class ContainerBinding implements IContainerBinding
	{
		private var _display: DisplayObject;
		
		public function ContainerBinding(display: DisplayObject = null)
		{
			this.display = display;
		}

		public function set display(value: DisplayObject): void
		{
			if (value != this.display)
			{
				this.preDisplayChange(value);
				var oldDisplay: DisplayObject = this.display;
				this._display = value;
				this.postDisplayChange(oldDisplay);
			}
		}
		public function get display(): DisplayObject
		{
			return this._display;
		}
		
		protected function preDisplayChange(newDisplay: DisplayObject): void
		{
		}
		
		protected function postDisplayChange(oldDisplay: DisplayObject): void
		{
		}		
	}
}