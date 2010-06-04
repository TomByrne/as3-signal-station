package org.farmcode.sodalityLibrary.utils.config.advice
{
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodalityLibrary.utils.config.adviceTypes.ISetConfigParamAdvice;
	
	public class SetConfigParamAdvice extends Advice implements ISetConfigParamAdvice
	{
		
		[Property(toString="true",clonable="true")]
		public function get paramName():String{
			return _paramName;
		}
		public function set paramName(value:String):void{
			if(_paramName!=value){
				_paramName = value;
			}
		}
		
		[Property(toString="true",clonable="true")]
		public function get value():*{
			return _value;
		}
		public function set value(value:*):void{
			if(_value!=value){
				_value = value;
			}
		}
		
		private var _value:*;
		private var _paramName:String;
		
		public function SetConfigParamAdvice(paramName:String=null, value:*=null){
			this.paramName = paramName;
			this.value = value;
		}
	}
}