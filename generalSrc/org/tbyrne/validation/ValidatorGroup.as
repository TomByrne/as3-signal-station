package org.tbyrne.validation
{
	import flash.utils.Dictionary;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.validation.validators.IValidator;

	public class ValidatorGroup implements IValidator
	{
		/**
		 * @inheritDoc
		 */
		public function get validChanged():IAct{
			if(!_validChanged)_validChanged = new Act();
			return _validChanged;
		}
		
		
		public function get validators():Array{
			return _validators;
		}
		public function set validators(value:Array):void{
			if(_validators!=value){
				var validator:IValidator;
				if(_validators){
					for each(validator in _validators){
						validator.validChanged.removeHandler(onValidChanged);
					}
				}
				_validators = value;
				if(!_valid){
					_errorDetails = [];
					_errorMap = new Dictionary();
					_totInvalid = 0;
				}
				if(_validators){
					var doCheck:Boolean;
					for each(validator in _validators){
						validator.validChanged.addHandler(onValidChanged);
						if(validator.lazyInvalidation){
							_notChecked.push(validator);
						}else if(!validator.getValid(true)){
							addErrors(validator,false);
							doCheck = true;
						}
					}
				}
				checkValidity();
			}
		}
		
		public function get errorDetails():Array{
			return _errorDetails;
		}
		
		
		public function get lazyInvalidation():Boolean{
			return _lazyInvalidation;
		}
		public function set lazyInvalidation(value:Boolean):void{
			if(_lazyInvalidation != value){
				_lazyInvalidation = value;
				if(!value && _invalidationPending){
					_invalidationPending = false;
					if(_validChanged)_validChanged.perform(this);
				}
			}
		}
		
		/* detect whether children are lazy and don't force them.
		remember which ones have got out of checking and when getValid(true)
		is called, call on to them*/
		
		private var _notChecked:Array = [];
		private var _invalidationPending:Boolean;
		private var _lazyInvalidation:Boolean;
		protected var _validChanged:Act;
		
		private var _validators:Array;
		private var _errorDetails:Array = [];
		// mapped IValidator -> [IErrorDetails,IErrorDetails]
		private var _errorMap:Dictionary = new Dictionary();
		private var _valid:Boolean = true;
		private var _totInvalid:int = 0;
		
		public function ValidatorGroup(lazyInvalidation:Boolean=false, validators:Array=null){
			this.lazyInvalidation = lazyInvalidation;
			this.validators = validators || [];
		}
		public function getValid(forceCheck:Boolean):Boolean{
			if(forceCheck && _notChecked.length){
				var doCheck:Boolean;
				for each(var validator:IValidator in _notChecked){
					if(validator.getValid(true)){
						clearErrors(validator,false);
						doCheck = true;
					}else{
						addErrors(validator,false);
						doCheck = true;
						_invalidationPending = true;
					}
				}
				if(doCheck)checkValidity();
				_notChecked = [];
			}
			if(_invalidationPending){
				if(forceCheck){
					_invalidationPending = false;
					if(_validChanged)_validChanged.perform(this);
				}else{
					// fake validity until forceCheck is true
					return true;
				}
			}
			return _valid;
		}
		
		protected function onValidChanged(from:IValidator):void{
			if(from.lazyInvalidation){
				if(_notChecked.indexOf(from)==-1){
					_notChecked.push(from);
				}
			}else if(from.getValid(true)){
				clearErrors(from,true);
			}else{
				addErrors(from,true);
			}
		}
		protected function clearErrors(from:IValidator, checkValid:Boolean):void{
			var existingErrors:Array = _errorMap[from];
			if(existingErrors){
				--_totInvalid;
				for each(var error:IErrorDetails in existingErrors){
					clearError(error);
				}
				delete _errorMap[from];
				if(checkValid)checkValidity();
			}
		}
		protected function addErrors(from:IValidator, checkValid:Boolean):void{
			++_totInvalid;
			var error:IErrorDetails;
			var existingErrors:Array = _errorMap[from];
			var newErrors:Array = from.errorDetails;
			if(existingErrors){
				var i:int=0;
				while(i<existingErrors.length){
					error = existingErrors[i];
					if(newErrors.indexOf(error)==-1){
						clearError(error);
						existingErrors.splice(i,1);
					}else{
						++i;
					}
				}
			}else{
				existingErrors = [];
				_errorMap[from] = existingErrors;
			}
			if(newErrors){
				for each(error in newErrors){
					if(existingErrors.indexOf(error)==-1){
						addError(error);
						existingErrors.push(error);
					}
				}
			}
			if(checkValid)checkValidity();
		}
		protected function addError(error:IErrorDetails):void{
			_errorDetails.push(error);
		}
		protected function clearError(error:IErrorDetails):void{
			var index:int = _errorDetails.indexOf(error);
			_errorDetails.splice(index,1);
		}
		protected function checkValidity():void{
			setValid(_totInvalid==0);
		}
		protected function setValid(valid:Boolean):void{
			if(_valid!=valid){
				_invalidationPending = false;
				_valid = valid;
				if(_validChanged){
					if(_valid){
						_validChanged.perform(this);
					}else if(!_lazyInvalidation){
						_validChanged.perform(this);
					}else{
						_invalidationPending = true;
					}
				}
			}
		}
	}
}