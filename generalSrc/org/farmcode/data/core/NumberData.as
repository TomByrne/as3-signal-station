package org.farmcode.data.core
{
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.data.dataTypes.INumberConsumer;
	import org.farmcode.data.dataTypes.INumberProvider;
	
	public class NumberData extends StringData implements INumberConsumer, INumberProvider
	{
		
		public function get numericalValue():Number{
			return _numericalValue;
		}
		public function set numericalValue(value:Number):void{
			if(_numericalValue!=value){
				_numericalValue = value;
				if(_numericalValueChanged)_numericalValueChanged.perform(this);
				if(isNaN(value)){
					super.stringValue = null;
				}else{
					super.stringValue = String(value);
				}
			}
		}
		
		override public function set stringValue(value:String):void{
			numericalValue = parseFloat(value);
		}
		override public function get value():*{
			return _numericalValue;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get numericalValueChanged():IAct{
			if(!_numericalValueChanged)_numericalValueChanged = new Act();
			return _numericalValueChanged;
		}
		override public function get valueChanged():IAct{
			return numericalValueChanged;
		}
		
		protected var _numericalValueChanged:Act;
		private var _numericalValue:Number;
		
		public function NumberData(numericalValue:Number=NaN)
		{
			this.numericalValue = numericalValue;
		}
	}
}