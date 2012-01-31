package org.tbyrne.display.validation
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;

	public class ValidationFlag
	{
		public static const ALWAYS_READY_CHECKER:Function = function(from:ValidationFlag):Boolean{return this};
		
		
		/**
		 * handler(validationFlag:ValidationFlag)
		 */
		public function get invalidateAct():IAct{
			if(!_invalidateAct)_invalidateAct = new Act();
			return _invalidateAct;
		}
		/**
		 * handler(validationFlag:ValidationFlag)
		 */
		public function get validateAct():IAct{
			if(!_validateAct)_validateAct = new Act();
			return _validateAct;
		}
		public function get valid():Boolean{
			return _valid;
		}
		public function get validating():Boolean{
			return _validating;
		}
		
		public function get readyForExecution():Boolean{
			return (readyChecker==null || readyChecker.call(null,this));
		}
		
		
		/**
		 * A function which returns a boolean, which represents whether this flag is ready to be validated.
		 * It should take one parameter, being the ValidationFlag itself.
		 */
		
		public function get readyChecker():Function{
			return _readyChecker;
		}
		public function set readyChecker(value:Function):void{
			if(_readyChecker!=value){
				_readyChecker = value;
				if(readyForExecution)validate();
			}
		}
		
		protected var _readyChecker:Function;
		
		
		/*public function get ready():Boolean{
			return _ready;
		}
		public function set ready(value:Boolean):void{
			if(_ready!=value){
				_ready = value;
				if(value && _pending)validate();
			}
		}
		
		private var _ready:Boolean;*/
		protected var _pending:Boolean;
		
		public var parameters:Array;
		
		protected var _validateAct:Act;
		protected var _invalidateAct:Act;
		
		protected var _validator:Function;
		protected var _valid:Boolean;
		protected var _validating:Boolean;
		protected var _executing:Boolean;
		
		public function ValidationFlag(validator:Function, valid: Boolean, parameters:Array=null, readyChecker:Function=null){
			_valid = valid;
			_validator = validator;
			this.parameters = parameters;
			
			if(readyChecker==null)readyChecker = ALWAYS_READY_CHECKER;
			_readyChecker = readyChecker;
		}
		public function invalidate():void{
			if(_valid){
				_valid = false;
				if(!_executing && _invalidateAct)_invalidateAct.perform(this);
			}
		}
		public function validate(force:Boolean=false):void{
			if(force || !_valid){
				if(readyForExecution && !_executing){
					_pending = false;
					_executing = true;
					_validating = true;
					if(parameters)_validator.apply(null,parameters);
					else _validator();
					_validating = false;
					_valid = true;
					_executing = false;
					
					if(_validateAct)_validateAct.perform(this);
				}else{
					if(force)invalidate();
					_pending = true;
				}
			}
		}
		public function release():void{
			parameters = null;
			_validator = null;
			if(_validateAct)_validateAct.removeAllHandlers();
			if(_invalidateAct)_invalidateAct.removeAllHandlers();
		}
	}
}