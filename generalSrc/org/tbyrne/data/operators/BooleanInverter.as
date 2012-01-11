package org.tbyrne.data.operators
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.data.dataTypes.IBooleanProvider;
	
	public class BooleanInverter implements IBooleanProvider
	{
		
		/**
		 * @inheritDoc
		 */
		public function get booleanValueChanged():IAct{
			return (_booleanValueChanged || (_booleanValueChanged = new Act()));
		}
		
		protected var _booleanValueChanged:Act;
		
		public function get target():IBooleanProvider{
			return _target;
		}
		public function set target(value:IBooleanProvider):void{
			if(_target!=value){
				if(_target){
					_target.booleanValueChanged.removeHandler(onTargetChanged);
				}
				_target = value;
				if(_target){
					_target.booleanValueChanged.addHandler(onTargetChanged);
					setValue(_target.booleanValue);
				}
			}
		}
		
		public function get booleanValue():Boolean{
			return _booleanValue;
		}
		
		private var _target:IBooleanProvider;
		private var _booleanValue:Boolean;
		
		public function BooleanInverter(target:IBooleanProvider=null, unsetValue:Boolean=false)
		{
			this.target = target;
			_booleanValue = unsetValue;
		}
		
		private function onTargetChanged(from:IBooleanProvider):void{
			setValue(_target.booleanValue);
		}
		
		protected function setValue(value:Boolean):void{
			if(_booleanValue!=value){
				_booleanValue = value;
				if(_booleanValueChanged)_booleanValueChanged.perform(this);
			}
		}
	}
}