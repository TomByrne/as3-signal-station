package org.farmcode.data.core
{
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.data.dataTypes.IDateConsumer;
	import org.farmcode.data.dataTypes.IDateProvider;
	
	public class DateData implements IDateProvider, IDateConsumer
	{
		public function get dateValue():Date{
			return _dateValue;
		}
		public function set dateValue(value:Date):void{
			if(!_dateValue || !value || _dateValue.time!=value.time){
				_dateValue = value;
				if(_dateValueChanged)_dateValueChanged.perform(this);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function get dateValueChanged():IAct{
			if(!_dateValueChanged)_dateValueChanged = new Act();
			return _dateValueChanged;
		}
		
		protected var _dateValueChanged:Act;
		private var _dateValue:Date;
		
		public function DateData(dateValue:Date=null){
			this.dateValue = dateValue;
		}
		
		
		public function get valueChanged():IAct{
			return dateValueChanged;
		}
		public function get value():*{
			return dateValue;
		}
	}
}