package org.tbyrne.data.core
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.data.dataTypes.IStringConsumer;
	import org.tbyrne.data.dataTypes.IStringProvider;
	import org.tbyrne.data.dataTypes.IValueProvider;

	public class StringData implements IStringConsumer, IStringProvider, IValueProvider
	{
		
		public function get stringValue():String{
			return _stringValue;
		}
		public function set stringValue(value:String):void{
			if(_stringValue!=value){
				_stringValue = value;
				if(_stringValueChanged)_stringValueChanged.perform(this);
			}
		}
		public function get value():*{
			return _stringValue;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get stringValueChanged():IAct{
			if(!_stringValueChanged)_stringValueChanged = new Act();
			return _stringValueChanged;
		}
		public function get valueChanged():IAct{
			return stringValueChanged;
		}
		
		protected var _stringValueChanged:Act;
		private var _stringValue:String;
		
		public function StringData(stringValue:String=null){
			this.stringValue = stringValue;
		}
		public function toString():String{
			return _stringValue;
		}
	}
}