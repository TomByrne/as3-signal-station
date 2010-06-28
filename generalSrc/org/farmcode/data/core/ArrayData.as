package org.farmcode.data.core
{
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.data.dataTypes.IArrayProvider;
	
	public class ArrayData implements IArrayProvider
	{
		
		public function get arrayValue():Array{
			return _arrayValue;
		}
		public function set arrayValue(value:Array):void{
			if(_arrayValue!=value){
				_arrayValue = value;
				if(_arrayValueChanged)_arrayValueChanged.perform(this);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function get arrayValueChanged():IAct{
			if(!_arrayValueChanged)_arrayValueChanged = new Act();
			return _arrayValueChanged;
		}
		public function get value():*{
			return arrayValue;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get valueChanged():IAct{
			return arrayValueChanged;
		}
		
		protected var _arrayValueChanged:Act;
		private var _arrayValue:Array;
		
		public function ArrayData(){
		}
	}
}