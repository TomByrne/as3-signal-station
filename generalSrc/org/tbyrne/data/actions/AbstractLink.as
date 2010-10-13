package org.tbyrne.data.actions
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.data.dataTypes.IStringProvider;
	
	public class AbstractLink extends TriggerableAction implements IStringProvider
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
		public function get value():*{
			return stringValue;
		}

		/**
		 * @inheritDoc
		 */			
		public function get stringValueChanged():IAct {
			if(!_stringValueChanged)_stringValueChanged = new Act();
			return _stringValueChanged;
		}
		/**
		 * @inheritDoc
		 */			
		public function get valueChanged():IAct {
			return stringValueChanged;
		}
		
		protected var _stringValueChanged:Act;
		private var _stringValue:String;
				
		public function AbstractLink(stringValue:String=null) {
			this.stringValue = stringValue;
		}				
	}
}