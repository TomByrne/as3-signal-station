package org.tbyrne.utils
{
	public class NumberUtils
	{
		public static function equals(num1:Number, num2:Number):Boolean{
			if(isNaN(num1)){
				return isNaN(num2);
			}else{
				return num1==num2;
			}
		}
	}
}