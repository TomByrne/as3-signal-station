package au.com.thefarmdigital.validation.object
{
	import au.com.thefarmdigital.utils.StringUtils;
	import au.com.thefarmdigital.validation.ValidationResult;
	import au.com.thefarmdigital.validation.Validator;
	import au.com.thefarmdigital.validation.ValidatorError;
	
	/**
	 * The DateComponentsValidator confirms that an array of three numbers make a valid date (in 
	 * the form [D,M,Y]). It is normally used in conjunction with a MultiSubjectValidator which
	 * collates these three numbers from several controls/objects.
	 */
	public class DateComponentsValidator extends Validator
	{
		public static const DATE_ERROR: String = "dateError";
		public static const MONTH_ERROR: String = "monthError";
		public static const YEAR_ERROR: String = "yearError";
		
		protected static const DELIMIT:RegExp = /[\/]/;
		
		protected var lastValidDate:Number = 1;
		protected var lastValidMonth:Number = 0;
		protected var lastValidYear:Number = (new Date()).fullYear;
		
		
		override protected function _validate(value:*, validationResult:ValidationResult):*{
			var doString:Boolean = (value is String);
			var components: Array;
			if(doString){
				components = (value as String).split(DELIMIT);
				var i:int=0;
				while(i<components.length){
					if(!(components[i] as String).length){
						components.splice(i,1);
					}else{
						i++;
					}
				}
			}else{
				components = value;
			}
			
			var date: Number;
			if(components.length)date = uint(components[0]);
			var month: Number;
			if(components.length>1)month = uint(components[1]) - 1;
			var year: Number;
			if(components.length>2)year =uint(components[2]);
			
			var complete:Boolean = (!isNaN(date) && !isNaN(month) && !isNaN(year));
			var dateCheck: Date = new Date(year, month, date);
			
			var strDate: String;
			var strMonth: String;
			var strYear: String;
			
			if(isNaN(date) || (complete && dateCheck.date != date)){
				validationResult.errors.push(new ValidatorError(DATE_ERROR));
				strDate = String(lastValidDate);
			}else{
				lastValidDate = date;
				strDate = String(date);
			}
			if(isNaN(month) || (complete && dateCheck.month != month)){
				validationResult.errors.push(new ValidatorError(MONTH_ERROR));
				strMonth = String(lastValidMonth+1);
			}else{
				lastValidMonth = month;
				strMonth = String(month+1);
			}
			if(isNaN(year) || (complete && dateCheck.fullYear != year)){
				validationResult.errors.push(new ValidatorError(YEAR_ERROR));
				strYear = String(lastValidYear);
			}else{
				lastValidYear = year;
				strYear = String(year);
			}
			if(doString){
				if(isNaN(date))return "";
				else{
					return StringUtils.pad(strDate,2,"0")+"/"+StringUtils.pad(strMonth,2,"0")+"/"+StringUtils.pad(strYear,4,"0");
				}
			}else{
				return value;
			}
		}
	}
}