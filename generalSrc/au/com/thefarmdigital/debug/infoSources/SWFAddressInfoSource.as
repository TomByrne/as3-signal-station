package au.com.thefarmdigital.debug.infoSources
{
	import com.asual.swfaddress.SWFAddress;
	import com.asual.swfaddress.SWFAddressEvent;
	
	import flash.events.Event;
	
	public class SWFAddressInfoSource extends AbstractInfoSource implements IEditableTextInfoSource
	{
		public function SWFAddressInfoSource(){
			SWFAddress.addEventListener(SWFAddressEvent.CHANGE, onChange);
		}
		
		public function set textOutput(value:String):void{
			SWFAddress.setValue(value);
		}
		public function get textOutput():String{
			return SWFAddress.getValue();
		}
		protected function onChange(e:Event):void{
			dispatchInfoChange();
		}
		public function setTextOutput(value:String):void{
			SWFAddress.setValue(value);
		}
	}
}