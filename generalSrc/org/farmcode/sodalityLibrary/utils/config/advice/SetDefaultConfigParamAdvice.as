package org.farmcode.sodalityLibrary.utils.config.advice
{
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodalityLibrary.utils.config.adviceTypes.ISetDefaultConfigParamAdvice;
	
	public class SetDefaultConfigParamAdvice extends Advice implements ISetDefaultConfigParamAdvice
	{
		
		[Property(toString="true",clonable="true")]
		public function get paramName():String{
			return _paramName;
		}
		public function set paramName(value:String):void{
			_paramName = value;
		}
		
		[Property(toString="true",clonable="true")]
		public function get value():String{
			return _value;
		}
		public function set value(value:String):void{
			_value = value;
		}
		
		private var _value:String;
		private var _paramName:String;
		
		public function SetDefaultConfigParamAdvice(paramName:String=null, value:String=null){
			this.paramName = paramName;
			this.value = value;
		}
	}
}