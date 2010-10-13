package org.tbyrne.actLibrary.external.config.acts
{
	import org.tbyrne.acting.acts.UniversalAct;
	
	public class AbstractConfigAct extends UniversalAct
	{
		public function get paramName():String{
			return _paramName;
		}
		public function set paramName(value:String):void{
			_paramName = value;
		}
		public function get value():*{
			return _value;
		}
		public function set value(value:*):void{
			_value = value;
		}
		
		private var _value:*;
		private var _paramName:String;
		
		public function AbstractConfigAct(){
			super();
		}
	}
}