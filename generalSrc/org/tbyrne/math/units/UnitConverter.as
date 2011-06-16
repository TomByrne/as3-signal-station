package org.tbyrne.math.units
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.data.dataTypes.INumberConsumer;
	import org.tbyrne.data.dataTypes.INumberData;
	import org.tbyrne.data.dataTypes.INumberProvider;

	public class UnitConverter implements INumberProvider, INumberConsumer
	{
		/**
		 * Converts a number's base
		 * 
		 * @param	from		The number to convert
		 * @param	fromType	The base of number from. Use the NUMBER constants
		 * 						to represent this
		 * @param	toType		The base to convert to. Use the NUMBER constants
		 * 						to represent this
		 * 
		 * @return	The converted number
		 */
		public static function convert(from:Number, fromType:Number,
									   toType:Number):Number{
			return (from*fromType)/toType;
		}
		
		/**
		 * Converts a number in to an array representing its different base values
		 * 
		 * @param	from		The number to convert
		 * @param	fromType	The base of the number from. Use the NUMBER 
		 * 						constants to represent this
		 * @param	toTypes		An array of bases to convert to
		 * 
		 * @return	An array of numbers. The index of each returned number will
		 * 			correspond to the indicies of the given toTypes array
		 */
		public static function breakdown(from:Number, fromType:Number,
										  toTypes:Array):Array
		{
			if(from<0)from = 0;
			var ret:Array = [];
			var remaining:Number = from;
			var length:int = toTypes.length;
			for(var i:int=0; i<length; ++i){
				var type:Number = toTypes[i];
				var amount:Number = Math.floor(convert(remaining,fromType,type));
				remaining -= convert(amount,type,fromType);
				ret[i] = amount;
			}
			return ret;
		}
		
		
		
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
		
		
		public function get stringValue():String{
			return _stringValue;
		}
		public function get value():*{
			return numericalValue;
		}
		public function get numericalValue():Number{
			return _numericalValue;
		}
		public function set numericalValue(value:Number):void{
			if(_numericalValue!=value){
				if(_consumer){
					_consumer.numericalValue = value;
				}else{
					_numericalValue = value;
				}
			}
		}
		
		
		public function get from():INumberProvider{
			return _from;
		}
		public function set from(value:INumberProvider):void{
			if(_from!=value){
				if(_from){
					_from.numericalValueChanged.removeHandler(onNumberChanged);
				}
				_from = value;
				if(_from){
					_from.numericalValueChanged.addHandler(onNumberChanged);
				}
				_consumer = (value as INumberConsumer);
				checkNumber();
			}
		}
		
		public function get fromType():Number{
			return _fromType;
		}
		public function set fromType(value:Number):void{
			if(_fromType!=value){
				_fromType = value;
				checkNumber();
			}
		}
		
		public function get toType():Number{
			return _toType;
		}
		public function set toType(value:Number):void{
			if(_toType!=value){
				_toType = value;
				checkNumber();
			}
		}
		
		public function get roundResult():Boolean{
			return _roundResult;
		}
		public function set roundResult(value:Boolean):void{
			if(_roundResult!=value){
				_roundResult = value;
				checkNumber();
			}
		}
		
		private var _roundResult:Boolean;
		private var _toType:Number;
		private var _fromType:Number;
		
		protected var _numericalValueChanged:Act;              
		private var _stringValue:String;
		private var _numericalValue:Number;
		
		private var _from:INumberProvider;
		private var _consumer:INumberConsumer;
		
		public function UnitConverter(from:INumberProvider, fromType:Number, toType:Number, roundResult:Boolean=false){
			this.roundResult = roundResult;
			this.from = from;
			this.fromType = fromType;
			this.toType = toType;
		}
		public function onNumberChanged(from:INumberProvider):void{
			checkNumber();
		}
		public function checkNumber():void{
			var newValue:Number;
			if(!isNaN(fromType) && !isNaN(toType) && from){
				newValue = convert(from.numericalValue,fromType,toType);
			}
			var bothNaN:Boolean = (isNaN(newValue) && isNaN(_numericalValue));
			if(!bothNaN){
				if(_roundResult){
					newValue = round(newValue);
				}
				if(newValue!=_numericalValue){
					_numericalValue = newValue;
					_stringValue = newValue.toString();
					if(_numericalValueChanged)_numericalValueChanged.perform(this);
				}
			}
		}
		private function round(value:Number): int{
			return value%1 ? (value>0?int(value+0.5) : int(value-0.5)) :value;
		}
		
	}
}