package org.farmcode.sodalityWebApp.data.navigation
{
	import org.farmcode.sodality.advice.IAdvice;	
	
	public class Link extends AbstractLink
	{
		public function set advice(value:IAdvice):void {
			if (_triggerAction != value) {
				_triggerAction = value;
			}
		}
		public function get advice():IAdvice {
			return _triggerAction;
		}
		
		private var _triggerAction:IAdvice;
		
		public function Link() {
			super();
		}
		
		override public function triggerAction():IAdvice{
			return _triggerAction;
		}				
	}
}