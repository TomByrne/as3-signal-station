package org.tbyrne.formatters.numberFormatters
{
	import org.tbyrne.data.dataTypes.INumberProvider;
	

	public class DecimalFormatter extends AbstractNumberFormatter
	{
		private static const REMOVE_CHARS:RegExp = /[^\d|\.|-]+/g;
		
		public function get decimalSeperator():String{
			return _decimalSeperator;
		}
		public function set decimalSeperator(value:String):void{
			if(_decimalSeperator!=value){
				_decimalSeperator = value;
				invalidateString();
			}
		}
		
		public function get digitGroupSeperator():String{
			return _digitGroupSeperator;
		}
		public function set digitGroupSeperator(value:String):void{
			if(_digitGroupSeperator!=value){
				_digitGroupSeperator = value;
				invalidateString();
			}
		}
		
		public function get digitGroupSize():uint{
			return _digitGroupSize;
		}
		public function set digitGroupSize(value:uint):void{
			if(_digitGroupSize!=value){
				_digitGroupSize = value;
				invalidateString();
			}
		}
		
		public function get decimalPlaces():int{
			if(_maxDecimalPlaces==_minDecimalPlaces){
				return _minDecimalPlaces;
			}else{
				return -1;
			}
		}
		public function set decimalPlaces(value:int):void{
			maxDecimalPlaces = minDecimalPlaces = value;
		}
		
		public function get minDecimalPlaces():int{
			return _minDecimalPlaces;
		}
		public function set minDecimalPlaces(value:int):void{
			if(_minDecimalPlaces!=value){
				_minDecimalPlaces = value;
				invalidateString();
			}
		}
		
		public function get maxDecimalPlaces():int{
			return _maxDecimalPlaces;
		}
		public function set maxDecimalPlaces(value:int):void{
			if(_maxDecimalPlaces!=value){
				_maxDecimalPlaces = value;
				invalidateString();
			}
		}
		
		private var _maxDecimalPlaces:int = -1;
		private var _minDecimalPlaces:int = -1;
		
		private var _digitGroupSize:uint = 3;
		private var _digitGroupSeperator:String = ",";
		
		private var _decimalSeperator:String = ".";
		
		/**
		 * Sometimes, as somebody is typing a value (e.g. -0), there
		 * is a need to store the sign outside of the number value
		 * so that it doesn't get formatted away while they're typing the
		 * value.
		 */
		protected var _useNegativeSign:Boolean = false;
		
		public function DecimalFormatter(numberProvider:INumberProvider=null){
			super(numberProvider);
		}
		
		override protected function formatString(number:Number):String{
			var ret:String;
			if(isNaN(number)){
				if(_useNegativeSign){
					_useNegativeSign = false;
					return "-";
				}else return "";
			}
			var roundNumber:int = int(number>0?number:-number);
			if(_digitGroupSeperator && _digitGroupSize>0 && roundNumber!=0){
				ret = "";
				var groupSize:int = int(Math.pow(10,_digitGroupSize));
				var remaining:int = roundNumber;
				var first:Boolean = true;
				while(remaining!=0){
					var value:int = int(remaining%groupSize);
					if(first){
						first = false;
					}else{
						ret = _digitGroupSeperator+ret;
					}
					remaining /= groupSize;
					if(remaining!=0){
						ret = String(Math.abs(value+groupSize)).slice(1)+ret;
					}else{
						ret = String(value)+ret;
					}
				}
				if(number<0){
					ret = "-"+ret;
				}
			}else{
				if(_useNegativeSign && number==0){
					ret = "-0";
				}else{
					ret = String(roundNumber);
				}
				_useNegativeSign = false;
			}
			if(_decimalSeperator && _maxDecimalPlaces){
				var decStr:String = String(number);
				var decIndex:int = decStr.indexOf(".");
				if(decIndex!=-1){
					decStr = decStr.slice(decIndex+1);
				}else{
					decStr = "";
				}
				if(_maxDecimalPlaces>0 && decStr.length>_maxDecimalPlaces){
					decStr = decStr.slice(0,_maxDecimalPlaces);
				}else{
					while(decStr.length<_minDecimalPlaces){
						decStr += "0";
					}
				}
				if(decStr.length){
					ret += _decimalSeperator+decStr;
				}
			}
			return ret;
		}
		override protected function parseString(string:String):Number{
			if(!string.length)return NaN;
			var decIndex:int=-1;
			if(_decimalSeperator){
				var first:Boolean = true;
				while((decIndex = string.indexOf(_decimalSeperator,decIndex+1))!=-1){
					if(first){
						first = false;
						if(_decimalSeperator!="."){
							string = string.slice(0,decIndex)+"."+string.slice(decIndex+1);
						}
					}else{
						// two decimal points, abort.
						return _numericalValue;
					}
				}
			}
			
			var digitIndex:int;
			while((digitIndex = string.indexOf(_digitGroupSeperator))!=-1 && (digitIndex<decIndex || decIndex==-1)){
				string = string.slice(0,digitIndex)+string.slice(digitIndex+1);
			}
			var containsIllegal:Boolean = REMOVE_CHARS.test(string);
			if(containsIllegal)string = string.replace(REMOVE_CHARS,"");
			var ret:Number;
			var newNegSign:Boolean;
			if(string=="-"){
				newNegSign = true;
			}else{
				ret = parseFloat(string);
				if(ret==0){
					newNegSign = (string.charAt(0)=="-");
				}else{
					newNegSign = false;
				}
			}
			if(newNegSign!=_useNegativeSign){
				_useNegativeSign = newNegSign;
				invalidateString();
			}
			if(!isNaN(ret) || !containsIllegal){
				return ret;
			}else{
				return _numericalValue;
			}
		}
	}
}