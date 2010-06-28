package org.farmcode.data.operators
{
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.data.dataTypes.INumberConsumer;
	import org.farmcode.data.dataTypes.INumberProvider;
	
	public class NumberRange extends NumberProxy
	{
		public function get maxProvider():INumberProvider{
			return _maxProvider;
		}
		public function set maxProvider(value:INumberProvider):void{
			if(_maxProvider!=value){
				if(_maxProvider){
					_maxProvider.numericalValueChanged.removeHandler(onProviderChanged);
				}
				_maxProvider = value;
				if(_maxProvider){
					_maxProvider.numericalValueChanged.addHandler(onProviderChanged);
				}
				checkValue();
			}
		}
		public function get minProvider():INumberProvider{
			return _minProvider;
		}
		public function set minProvider(value:INumberProvider):void{
			if(_minProvider!=value){
				if(_minProvider){
					_minProvider.numericalValueChanged.removeHandler(onProviderChanged);
				}
				_minProvider = value;
				if(_minProvider){
					_minProvider.numericalValueChanged.addHandler(onProviderChanged);
				}
				checkValue();
			}
		}
		
		private var _minProvider:INumberProvider;
		private var _maxProvider:INumberProvider;
		
		public function NumberRange(numberProvider:INumberProvider=null){
			super(numberProvider);
		}
		override protected function validateValue(value:Number):Number{
			var newVal:Number = value;
			if(!isNaN(newVal)){
				if(_minProvider && !isNaN(_minProvider.numericalValue) && _minProvider.numericalValue>newVal){
					newVal = _minProvider.numericalValue;
				}
				if(_maxProvider && !isNaN(_maxProvider.numericalValue) && _maxProvider.numericalValue<newVal){
					newVal = _maxProvider.numericalValue;
				}
			}
			return newVal;
		}
	}
}