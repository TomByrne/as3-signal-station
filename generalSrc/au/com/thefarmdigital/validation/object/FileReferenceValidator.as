package au.com.thefarmdigital.validation.object
{
	import au.com.thefarmdigital.validation.ValidationResult;
	import au.com.thefarmdigital.validation.ValidatorError;
	import au.com.thefarmdigital.validation.number.NumberValidator;
	
	import flash.net.FileReference;
	
	/**
	 * The FileReferenceValidator allows any file picking class to be validated by
	 * minimum/maximum file size and an array of valid file extensions.
	 */
	public class FileReferenceValidator extends NumberValidator
	{
		public static const INVALID_EXTENSION:String = "invalidExtension";
		
		public function get validExtensions():Array{
			return _validExtensions;
		}
		public function set validExtensions(value:Array):void{
			if(_validExtensions != value){
				_validExtensions = value;
				validateIfLive();
			}
		}
		
		private var _validExtensions:Array;
		
		public function FileReferenceValidator(mandatory: Boolean = false, minSize: Number = NaN, 
			maxSize: Number = NaN, validExtensions: Array = null){
			super(mandatory,minSize,maxSize);
			commitLiveChanges = false;
			this.validExtensions = validExtensions;
		}
		
		override protected function _validate(value:*, validationResult:ValidationResult):*{
			var fileRef: FileReference = value;			
			
			var size: Number;
			if(fileRef){
				try{
					size = fileRef.size;
				}catch (e:Error){
					size = NaN;
				}
			}

			super._validate(size,validationResult);
			if (!validationResult.errors.length){
				// Validate extension
				if (this.validExtensions != null && this.validExtensions.length > 0){
					var filenameSplit: Array = String(fileRef.name).split(".");
					var extension:String = filenameSplit[filenameSplit.length-1].toLowerCase();
					for (var i: uint = 0; i < this.validExtensions.length; ++i){
						var testExtension: String = this.validExtensions[i];
						if (testExtension.toLowerCase() == extension){
							return value;
						}
					}
					validationResult.errors.push(new ValidatorError(FileReferenceValidator.INVALID_EXTENSION));
				}
			}
			
			return value;
		}
	}
}