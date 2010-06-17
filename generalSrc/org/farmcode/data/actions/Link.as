package org.farmcode.data.actions
{
	import org.farmcode.acting.actTypes.IAct;
	
	public class Link extends AbstractLink
	{
		public function set act(value:IAct):void {
			_triggerAct = value;
		}
		public function get act():IAct {
			return _triggerAct;
		}
		
		private var _triggerAct:IAct;
		
		public function Link() {
			super();
		}
		
		override protected function getAct():IAct{
			return _triggerAct;
		}				
	}
}