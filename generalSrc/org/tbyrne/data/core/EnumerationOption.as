package org.tbyrne.data.core
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.data.dataTypes.IStringProvider;
	
	public class EnumerationOption extends BooleanData implements IStringProvider
	{
		
		override public function get value():*{
			return _value;
		}
		public function set value(value:*):void{
			if(_value!=value){
				_value = value;
			}
		}
		
		public function get stringValue():String{
			return _stringValue;
		}
		public function set stringValue(value:String):void{
			if(_stringValue!=value){
				_stringValue = value;
				if(_stringValueChanged)_stringValueChanged.perform(this);
			}
		}
		override public function set booleanValue(value:Boolean):void{
			super.booleanValue = value;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get stringValueChanged():IAct{
			if(!_stringValueChanged)_stringValueChanged = new Act();
			return _stringValueChanged;
		}
		
		protected var _stringValueChanged:Act;
		private var _stringValue:String;
		private var _value:*;
		
		public function EnumerationOption(stringValue:String=null)
		{
			this.stringValue = stringValue;
		}
	}
}