package org.farmcode.sodality
{
	public class TriggerTiming
	{
		public static const BEFORE:String = "before";
		public static const AFTER:String = "after";
		public static const BEFORE_AND_AFTER:String = "beforeAfter";
		
		public static function validate(value:String):Boolean{
			switch(value){
				case BEFORE:
				case AFTER:
				case BEFORE_AND_AFTER:
				return true;
			}
			return false;
		}
	}
}