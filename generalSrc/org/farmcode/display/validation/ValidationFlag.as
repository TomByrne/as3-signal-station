package org.farmcode.display.validation
{
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;

	public class ValidationFlag
	{
		public function get invalidateAct():IAct{
			if(!_invalidateAct)_invalidateAct = new Act();
			return _invalidateAct;
		}
		public function get validateAct():IAct{
			if(!_validateAct)_validateAct = new Act();
			return _validateAct;
		}
		public function get valid():Boolean{
			return _valid;
		}
		protected var _validateAct:Act;// (validationFlag:ValidationFlag)
		protected var _invalidateAct:Act;// (validationFlag:ValidationFlag)
		
		protected var _validator:Function;
		protected var _valid:Boolean;
		
		public function ValidationFlag(validator:Function, valid: Boolean){
			_valid = valid;
			_validator = validator;
		}
		public function invalidate():void{
			if(_valid){
				_valid = false;
				if(_invalidateAct)_invalidateAct.perform(this);
			}
		}
		public function validate(force:Boolean=false):void{
			if(force || !_valid){
				_validator();
				_valid = true;
				if(_validateAct)_validateAct.perform(this);
			}
		}
	}
}