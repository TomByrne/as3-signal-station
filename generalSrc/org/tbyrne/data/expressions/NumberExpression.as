package org.tbyrne.data.expressions
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.data.dataTypes.INumberProvider;
	import org.tbyrne.data.dataTypes.IStringProvider;
	
	public class NumberExpression extends Expression implements INumberProvider, IStringProvider
	{
		public function get numericalValue():Number{
			return _numericalValue;
		}
		public function get stringValue():String{
			return _stringValue;
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
			if(!_stringValueChanged)_stringValueChanged = new Act();
			return _stringValueChanged;
		}
		
		protected var _numericalValueChanged:Act;
		protected var _stringValueChanged:Act;
		private var _numericalValue:Number;
		private var _stringValue:String;
		
		override protected function setResult(result:*) : void{
			var newNum:Number;
			if(typeof(result)=="number"){
				newNum = result;
			}else{
				newNum = parseFloat(result);
			}
			if(newNum!=_numericalValue && !(isNaN(newNum) && isNaN(_numericalValue))){
				_numericalValue = newNum;
				if(_numericalValueChanged)_numericalValueChanged.perform(this);
			}
			
			
			var newStr:String;
			if(typeof(result)=="string"){
				newStr = result;
			}else{
				if(isNaN(newNum))newStr = null;
				else newStr = String(newNum);
			}
			if(newStr!=_stringValue){
				_stringValue = newStr;
				if(_stringValueChanged)_stringValueChanged.perform(this);
			}
			super.setResult(result);
		}
	}
}