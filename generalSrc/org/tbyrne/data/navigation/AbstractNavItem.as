package org.tbyrne.data.navigation
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.data.core.StringData;
	import org.tbyrne.data.dataTypes.IBooleanData;
	
	public class AbstractNavItem extends StringData implements IBooleanData
	{
		
		/**
		 * @inheritDoc
		 */
		public function get booleanValue():Boolean{
			return _booleanValue;
		}
		public function set booleanValue(value:Boolean):void{
			if(!isSelectable())value = false;
			if(_booleanValue!=value){
				_booleanValue = value;
				if(_booleanValueChanged)_booleanValueChanged.perform(this);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function get booleanValueChanged():IAct{
			if(!_booleanValueChanged)_booleanValueChanged = new Act();
			return _booleanValueChanged;
		}
		
		protected var _booleanValueChanged:Act;
		private var _booleanValue:Boolean;
		
		
		
		public function AbstractNavItem(stringValue:String=null){
			super(stringValue);
		}
		protected function isSelectable():Boolean{
			return false;
		}
	}
}