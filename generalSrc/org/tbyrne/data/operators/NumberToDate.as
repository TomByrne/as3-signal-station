package org.tbyrne.data.operators
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.data.dataTypes.IDateConsumer;
	import org.tbyrne.data.dataTypes.IDateProvider;
	import org.tbyrne.data.dataTypes.INumberProvider;
	
	public class NumberToDate extends NumberProxy implements IDateConsumer, IDateProvider
	{
		
		/**
		 * @inheritDoc
		 */
		public function get dateValueChanged():IAct{
			if(!_dateValueChanged)_dateValueChanged = new Act();
			return _dateValueChanged;
		}
		
		public function get dateValue():Date{
			return _dateValue;
		}
		public function set dateValue(value:Date):void{
			if(_dateValue!=value){
				_dateValue = value;
				if(_dateValueChanged)_dateValueChanged.perform(this);
			}
		}
		
		protected var _dateValueChanged:Act;
		private var _dateValue:Date;
		
		
		public function NumberToDate(numberProvider:INumberProvider=null){
			super(numberProvider);
		}
		override protected function validateValue(value:Number):Number{
			if(isNaN(value) || value<0){
				dateValue = null;
			}else if(_dateValue){
				if(_dateValue.time!=value){
					_dateValue.time = value;
					if(_dateValueChanged)_dateValueChanged.perform(this);
					return _dateValue.time;
				}
			}else{
				dateValue = new Date(value);
			}
			return value;
		}
	}
}