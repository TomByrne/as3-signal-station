package com.asual.swfaddress
{
	public class SWFAddressUtilities
	{
		// this is taken from the SWFAddress class (because it's private)
        public static function strictCheck(value:String, force:Boolean, strict:Boolean):String {
            if (strict) {
				if(!value || value == '')value = "/";
				else if (force) {
					if (value.substr(0, 1) != '/') value = '/' + value;
                    var qi:Number = value.indexOf('?');
                    if (qi != -1) {
                        value = value.substr(qi - 1, 1) != '/' ? value.substr(0, qi) + '/' + value.substr(qi) : value;
                    } else {
                        if (value.substr(value.length - 1) != '/') value += '/';
                    }
                }
            }
            return value;
        }
	}
}