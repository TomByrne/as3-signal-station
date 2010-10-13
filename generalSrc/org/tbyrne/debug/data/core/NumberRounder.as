package org.tbyrne.debug.data.core
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.data.dataTypes.INumberProvider;
	
	public class NumberRounder implements INumberProvider
	{
		
		/**
		 * @inheritDoc
		 */
		public function get numericalValueChanged():IAct{
			if(!_numericalValueChanged)_numericalValueChanged = new Act();
			return _numericalValueChanged;
		}
		/**
		 * @inheritDoc
		 */
		public function get stringValueChanged():IAct{
			return numericalValueChanged;
		}
		/**
		 * @inheritDoc
		 */
		public function get valueChanged():IAct{
			return numericalValueChanged;
		}
		
		
		public function get numberProvider():INumberProvider{
			return _numberProvider;
		}
		public function set numberProvider(value:INumberProvider):void{
			if(_numberProvider!=value){
				if(_numberProvider){
					_numberProvider.numericalValueChanged.removeHandler(onNumChanged);
				}
				_numberProvider = value;
				if(value){
					_numberProvider.numericalValueChanged.addHandler(onNumChanged);
					setNumValue(value.numericalValue);
				}else setNumValue(NaN);
			}
		}
		public function get numericalValue():Number{
			return _numericalValue;
		}
		public function get stringValue():String{
			return String(numericalValue);
		}
		public function get value():*{
			return numericalValue;
		}
		
		protected var _numericalValueChanged:Act;
		private var _numberProvider:INumberProvider;
		private var _numericalValue:Number;
		
		public function NumberRounder(numberProvider:INumberProvider=null){
			this.numberProvider = numberProvider;
		}
		
		protected function onNumChanged(from:INumberProvider):void{
			setNumValue(from.numericalValue);
		}
		protected function setNumValue(number:Number):void{
			if(!isNaN(number))number = int(number+0.5);
			if(_numericalValue!=number){
				_numericalValue = number;
				if(_numericalValueChanged)_numericalValueChanged.perform(this);
			}
		}
	}
}