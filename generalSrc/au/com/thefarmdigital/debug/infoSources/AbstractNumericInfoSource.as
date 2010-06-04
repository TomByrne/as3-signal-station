package au.com.thefarmdigital.debug.infoSources
{
	import org.farmcode.math.UnitConversion;

	public class AbstractNumericInfoSource extends AbstractInfoSource implements INumericInfoSource, ITextInfoSource
	{
		public function get textUnit():Number{
			return _textUnit;
		}
		public function set textUnit(value:Number):void{
			_textUnit = value;
		}
		public function get rounding():int{
			return _rounding;
		}
		public function set rounding(value:int):void{
			_rounding = value;
		}
		protected var _naturalUnit:Number;
		private var _textUnit:Number;
		private var _rounding:int = -1;
		
		public function AbstractNumericInfoSource(labelColour:Number=0xffffff){
			super(labelColour);
		}
		
		override public function get output(): *{
			return numericOutput;
		}
		public function get numericOutput(): Number{
			return NaN;
		}
		public function get textOutput() : String{
			var amount:Number = numericOutput;
			if(!isNaN(_naturalUnit) && !isNaN(textUnit)){
				amount = UnitConversion.convert(amount,_naturalUnit,textUnit)
			}
			if(_rounding==0){
				return String(Math.round(_rounding));
			}else if(_rounding>0){
				return amount.toFixed(_rounding);
			}else{
				return String(amount);
			}
		}
	}
}