package org.tbyrne.display.validation
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;

	public class ValidationFlag
	{
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
		
		public var parameters:Array;
		
		protected var _validateAct:Act;
		protected var _invalidateAct:Act;
		
		protected var _validator:Function;
		protected var _valid:Boolean;
		protected var _executing:Boolean;
		
		public function ValidationFlag(validator:Function, valid: Boolean, parameters:Array=null){
			_valid = valid;
			_validator = validator;
			this.parameters = parameters;
		}
		public function invalidate():void{
			if(_valid){
				_valid = false;
				if(!_executing && _invalidateAct)_invalidateAct.perform(this);
			}
		}
		public function validate(force:Boolean=false):void{
			if(force || !_valid){
				_valid = true;
				_executing = true;
				if(parameters)_validator.apply(null,parameters);
				else _validator();
				_executing = false;
				
				if(_validateAct)_validateAct.perform(this);
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