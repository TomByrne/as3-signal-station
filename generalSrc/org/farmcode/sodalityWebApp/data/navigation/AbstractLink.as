package org.farmcode.sodalityWebApp.data.navigation
{
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;	
	import org.farmcode.data.dataTypes.IStringProvider;
	import org.farmcode.data.dataTypes.ITriggerableAction;
	import org.farmcode.sodality.advice.IAdvice;	
	
	public class AbstractLink implements IStringProvider, ITriggerableAction
	{
		public function get stringValue():String{
			return _stringValue;
		}
		public function set stringValue(value:String):void{
			if(_stringValue != value){
				_stringValue = value;
				if(_stringValueChanged)_stringValueChanged.perform(this)
			}
		}

		/**
		 * @inheritDoc
		 */			
		public function get stringValueChanged():IAct {
			if(!_stringValueChanged)_stringValueChanged = new Act();
			return _stringValueChanged;
		}
	
		public function triggerAction():IAdvice {
			return null;
		}		
				
		protected var _stringValueChanged:Act;
				
		private var _stringValue:String;
				
		public function AbstractLink() { }				
	}
}