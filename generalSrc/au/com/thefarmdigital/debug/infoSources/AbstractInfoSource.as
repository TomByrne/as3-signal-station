package au.com.thefarmdigital.debug.infoSources
{
	import au.com.thefarmdigital.debug.events.InfoSourceEvent;
	
	import flash.events.EventDispatcher;

	[Event(name="outputChange", type="au.com.thefarmdigital.debug.events.InfoSourceEvent")]
	public class AbstractInfoSource extends EventDispatcher implements IInfoSource
	{
		private var _enabled: Boolean = true;
		private var _labelColour: Number = 0xffffff;
		
		public function AbstractInfoSource(labelColour:Number=0xffffff){
			this.labelColour = labelColour;
		}
		
		public function get output(): *{
			return null;
		}
		public function get labelColour(): Number{
			return this._labelColour;
		}
		public function set labelColour(value: Number): void{
			if (this.labelColour != value){
				this._labelColour = value;
			}
		}
		public function get enabled(): Boolean{
			return this._enabled;
		}
		public function set enabled(value: Boolean): void{
			if (this.enabled != value){
				this._enabled = value;
			}
		}
		
		protected function dispatchInfoChange(): void{
			var event: InfoSourceEvent = new InfoSourceEvent(InfoSourceEvent.INFO_CHANGE);
			this.dispatchEvent(event);
		}
	}
}