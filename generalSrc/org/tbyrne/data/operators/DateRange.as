package org.tbyrne.data.operators
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.data.dataTypes.IDateConsumer;
	import org.tbyrne.data.dataTypes.IDateProvider;
	
	public class DateRange implements IDateConsumer, IDateProvider
	{
		
		public function get dateProvider():IDateProvider{
			return _dateProvider;
		}
		public function set dateProvider(value:IDateProvider):void{
			if(_dateProvider!=value){
				if(_dateProvider){
					_dateProvider.dateValueChanged.removeHandler(onProviderChanged);
				}
				_dateProvider = value;
				_dateConsumer = (value as IDateConsumer);
				if(_dateProvider){
					_dateProvider.dateValueChanged.addHandler(onProviderChanged);
					setDateValue(_dateProvider.dateValue);
				}else{
					setDateValue(null);
				}
			}
		}
		
		
		public function get minDate():Date{
			return _minDate;
		}
		public function set minDate(value:Date):void{
			if(_minDate!=value){
				_minDate = value;
				validateDate(true);
			}
		}
		
		public function get maxDate():Date{
			return _maxDate;
		}
		public function set maxDate(value:Date):void{
			if(_maxDate!=value){
				_maxDate = value;
				validateDate(true);
			}
		}
		
		public function get dateValue():Date{
			return _dateValue;
		}
		public function set dateValue(value:Date):void{
			setDateValue(value);
		}
		
		public function get nullOnInvalid():Boolean{
			return _nullOnInvalid;
		}
		public function set nullOnInvalid(value:Boolean):void{
			if(_nullOnInvalid!=value){
				_nullOnInvalid = value;
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function get dateValueChanged():IAct{
			if(!_dateValueChanged)_dateValueChanged = new Act();
			return _dateValueChanged;
		}
		
		
		public function get valueChanged():IAct{
			return dateValueChanged;
		}
		public function get value():*{
			return dateValue;
		}
		
		private var _dateProvider:IDateProvider;
		private var _dateConsumer:IDateConsumer;
		protected var _dateValueChanged:Act;
		private var _dateValue:Date;
		private var _maxDate:Date;
		private var _minDate:Date;
		private var _nullOnInvalid:Boolean = true;
		
		public function DateRange(minDate:Date=null, maxDate:Date=null){
			this.minDate = minDate;
			this.maxDate = maxDate;
		}
		protected function setDateValue(value:Date):void{
			if(!value && !_dateValue)return;
			
			if((value && !_dateValue) ||
				(!value && _dateValue) ||
				(value.time!=_dateValue.time)){
				
				if(value){
					if(!_dateValue){
						_dateValue = new Date(value.time);
					}else{
						_dateValue.time = value.time;
					}
					validateDate(false);
				}else{
					_dateValue = null;
				}
				if(_dateValueChanged){
					_dateValueChanged.perform(this);
				}
			}
		}
		protected function validateDate(triggerChange:Boolean):void{
			if(_dateValue){
				var change:Boolean;
				if(_minDate && _minDate.time>_dateValue.time){
					change = true;
					if(_nullOnInvalid){
						_dateValue = null;
					}else{
						_dateValue.time = _minDate.time;
					}
				}else if(_maxDate && _maxDate.time<_dateValue.time){
					change = true;
					if(_nullOnInvalid){
						_dateValue = null;
					}else{
						_dateValue.time = _maxDate.time;
					}
				}
				if(triggerChange && change && _dateValueChanged){
					_dateValueChanged.perform(this);
				}
			}
		}
		protected function onProviderChanged(from:IDateProvider):void{
			setDateValue(from.dateValue);
		}
	}
}