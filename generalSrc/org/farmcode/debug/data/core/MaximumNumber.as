package org.farmcode.debug.data.core
{
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.data.dataTypes.INumberProvider;
	
	public class MaximumNumber implements INumberProvider
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
		
		public function MaximumNumber(numberProvider:INumberProvider=null){
			this.numberProvider = numberProvider;
		}
		
		protected function onNumChanged(from:INumberProvider):void{
			if(isNaN(_numericalValue) || _numericalValue<from.numericalValue){
				setNumValue(from.numericalValue);
			}
		}
		protected function setNumValue(number:Number):void{
			if(_numericalValue!=number){
				_numericalValue = number;
				if(_numericalValueChanged)_numericalValueChanged.perform(this);
			}
		}
	}
}