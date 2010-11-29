package org.tbyrne.data.navigation
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.data.core.StringData;
	import org.tbyrne.data.dataTypes.IBooleanConsumer;
	import org.tbyrne.data.dataTypes.IBooleanProvider;

	public class TogglableNavItem extends StringData implements IBooleanProvider, IBooleanConsumer
	{
		/**
		 * @inheritDoc
		 */
		public function get booleanValueChanged():IAct{
			return (_booleanValueChanged || (_booleanValueChanged = new Act()));
		}
		protected var _booleanValueChanged:Act;
		
		
		public function get booleanValue():Boolean{
			return _booleanValue;
		}
		public function set booleanValue(value:Boolean):void{
			if(_booleanValue!=value){
				_booleanValue = value;
				if(_booleanValueChanged)_booleanValueChanged.perform(this);
			}
		}
		
		private var _booleanValue:Boolean;
		
		public function TogglableNavItem(stringValue:String){
			super(stringValue);
		}
	}
}