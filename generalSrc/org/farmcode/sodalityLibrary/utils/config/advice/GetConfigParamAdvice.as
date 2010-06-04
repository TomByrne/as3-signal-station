package org.farmcode.sodalityLibrary.utils.config.advice
{
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodalityLibrary.utils.config.adviceTypes.IGetConfigParamAdvice;

	public class GetConfigParamAdvice extends Advice implements IGetConfigParamAdvice
	{
		[Property(toString="true",clonable="true")]
		public function get paramName():String{
			return _paramName;
		}
		public function set paramName(value:String):void{
			_paramName = value
		}
		
		[Property(toString="true",clonable="true")]
		public function get value():String{
			return _value;
		}
		public function set value(value:String):void{
			_value = value
		}
		
		private var _paramName:String;
		private var _value:String;
		
		public function GetConfigParamAdvice(paramName:String=null)
		{
			super();
			this.paramName = paramName;
		}
		
	}
}