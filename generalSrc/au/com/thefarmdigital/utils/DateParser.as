package au.com.thefarmdigital.utils
{
	public class DateParser
	{
    	public static const VALID_PATTERN_CHARS:Array = ["Y","M","D","A","E","H","J","K","L","N","S"];
    	public static const MERIDIANS:Array = ["AM","PM"];
    	public static const DAY_NAMES_SHORT:Array = ["Sun","Mon","Tues","Wed","Thurs","Fri","Sat"];
    	public static const DAY_NAMES_LONG:Array = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"];
    	public static const MONTH_NAMES_SHORT:Array = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sept","Oct","Nov","Dec"];
    	public static const MONTH_NAMES_LONG:Array = ["January","February","March","April","May","June","July","August","September","October","November","December"];
    	
		public static function format(date:Date, formatString:String):String{
			var terms:Array = DateParser.findTerms(formatString);
			terms.sort(termSortingFunction);
			var ret:String = formatString;
			var length:int = terms.length;
			for(var i:int=0; i<length; ++i){
				var term:DateTerm = terms[i];
				var top:String = ret.slice(0,term.index);
				var encoded:String = encodePart(date,term.key,term.count)
				var tail:String = ret.slice(term.index+term.count);
				ret = top+encoded+tail;
			}
			return ret;
	    }
		public static function parse(dateStr:String, formatString:String):Date{
			var terms:Array = findTerms(formatString);
			terms.sort(termSortingFunction);
			var regStr:String = "";
			while(regStr.length<formatString.length) regStr += ".";
			
			var parseInfo:Object = {};
			var length:int = terms.length;
			for(var i:int=0; i<length; ++i){
				var term:DateTerm = terms[i];
				regStr = regStr.slice(0,term.index)+"([0-9]{1,"+term.count+"})"+regStr.slice(term.index+term.count);
			}
			var regExp:RegExp = new RegExp(regStr);
			var results:Object = regExp.exec(dateStr);
			
			
			var date:Date = new Date();
			date.setTime(0);
			
			if(results && results.length){
				length = results.length;
				for(i=1; i<length; ++i){
					var datePart:String = results[i];
					term = terms[terms.length-i];
					decodePart(date,datePart,term.key,term.count,parseInfo);
				}
				return date
			}else{
				return null;
			}
		}
		public static function getFirstDay(year:Number, month:Number):Number {
			return new Date(year, month, 1).getDay();
		}
		public static function monthLength(year:Number, month:Number):Number {
			if (month == 1) {
				if (((year%4 == 0) && (year%100 != 0)) || (year%400 == 0)) {
					return 29;
				} else {
					return 28;
				}
			} else if (month == 3 || month == 5 || month == 8 || month == 10) {
				return 30;
			} else {
				return 31;
			}
		}
		private static function findTerms(formatString:String):Array{
			var terms:Array = [];
			var length:int = VALID_PATTERN_CHARS.length;
			for(var i:int=0; i<length; ++i){
				var char:String = VALID_PATTERN_CHARS[i];
				var index:Number = formatString.indexOf(char);
				if(index!=-1){
					var count:Number = 1;
					while(formatString.indexOf(char,index+count)!=-1){
						count++;
					}
					if(!isNaN(index)){
						terms.push(new DateTerm(char, index, count));
					}
				}
			}
			return terms;
		}
		private static function termSortingFunction(term1:DateTerm,term2:DateTerm):Number{
			if(term1.index<term2.index)return 1;
			else if(term1.index>term2.index)return -1;
			else return 0;
		}
		private static function encodePart(date:Date,key:String,count:Number):String{
			switch (key){
				case "Y":{
					// year
					if (count < 3)return date.fullYear.toString().slice(2);
					else return zeroPadString(date.fullYear.toString(),count);
					break;
				}
				case "M":{
					// month in year
					if (count < 3)return zeroPadString((date.month+1).toString(),count);
					else if (count == 3)return MONTH_NAMES_SHORT[date.month];
					else return MONTH_NAMES_LONG[date.month];
					break;
				}
				case "D":{
					// day in month
					return zeroPadString(date.date.toString(),count);
					break;
				}
				case "E":{
					if (count < 3)return zeroPadString(date.day.toString(),count);
					else if(count == 3)return DAY_NAMES_SHORT[date.day];
					else return DAY_NAMES_LONG[date.day];
					break;
				}
				case "A":{
					// am/pm marker
					return MERIDIANS[date.hours<10 || date.hours>22 ?0:1];
					break;
				}
				case "H":{
					// hour in day (1-24)
					return zeroPadString((date.hours+1).toString(),count);
					break;
				}
				case "J":{
					// hour in day (0-23)
					return zeroPadString(date.hours.toString(),count);
					break;
				}
				case "K":{
					// hour in am/pm (0-11)
					return zeroPadString((date.hours%12).toString(),count)
					break;
				}
				case "L":{
					// hour in am/pm (1-12)
					return zeroPadString(((date.hours%12)+1).toString(),count)
					break;
				}
				case "N":{
					// minutes in hour
					return zeroPadString(date.minutes.toString(),count)
					break;
				}
				case "S":{
					// seconds in minute
					return zeroPadString(date.seconds.toString(),count)
					break;
				}
			}
			return null;
		}
		private static function decodePart(date:Date,data:String,key:String,count:Number,parseInfo:Object):void{
			var numData:Number = parseInt(data);
			switch (key){
				case "Y":{
					// year
					var year:int;
					if (count < 3){
						// if two digits assume it's within 100 years of 1970
						if(numData<70)numData += 100;
						year = 1900+numData;
					}else year = numData;
					date.setFullYear(numData)
					break;
				}
				case "M":{
					// month in year
					var month:int;
					if (count < 3)month = numData-1;
					else if (count == 3)month = findIndex(data, MONTH_NAMES_SHORT);
					else month = findIndex(data, MONTH_NAMES_LONG);
					date.setMonth(month);
					break;
				}
				case "D":{
					// day in month
					date.setDate(numData);
					break;
				}
				case "E":{
					// day in the week
					// can't handle this (i.e. there is no way of knowing which week)
					break;
				}
				case "A":{
					// am/pm marker
					parseInfo.meridian = findIndex(data, MERIDIANS);
					break;
				}
				case "H":{
					// hour in day (1-24)
					date.setHours(numData-1);
					break;
				}
				case "J":{
					// hour in day (0-23)
					date.setHours(numData);
					break;
				}
				case "K":{
					// hour in am/pm (0-11)
					parseInfo.meridianHour = numData;
					break;
				}
				case "L":{
					// hour in am/pm (1-12)
					parseInfo.meridianHour = numData-1;
					break;
				}
				case "N":{
					// minutes in hour
					date.setMinutes(numData);
					break;
				}
				case "S":{
					// seconds in minute
					date.setSeconds(numData);
					break;
				}
			}
			if(!isNaN(parseInfo.meridian) && !isNaN(parseInfo.meridianHour)){
				var shift:Boolean = (parseInfo.meridian==1);
				if(parseInfo.meridianHour==11)shift = !shift;
				date.setHours(parseInfo.meridianHour+(shift?12:0));
				parseInfo.meridian = parseInfo.meridianHour = NaN;
			}
		}
		private static function zeroPadString(str:String, count:Number):String{
			while(str.length<count){
				str = "0"+str;
			}
			return str;
		}
		private static function findIndex(of:String, within:Array):Number{
			of = of.toLowerCase();
			var length:int = within.length;
			for(var i:int=0; i<length; ++i){
				if(within[i].toLowerCase()==of)return i;
			}
			return NaN;
		}
		
		private var _formatString:String;
		public function get formatString():String{
			return _formatString;
		}
		public function set formatString(to:String):void{
			_formatString = to;
		}
		
		public function parse(dateStr:String):Date{
			return DateParser.parse(dateStr,formatString);
		}
	}
}
class DateTerm{
	public var key:String;
	public var index:Number;
	public var count:Number;
	public function DateTerm(key:String,index:Number,count:Number){
		this.key = key;
		this.index = index;
		this.count = count;
	}
}