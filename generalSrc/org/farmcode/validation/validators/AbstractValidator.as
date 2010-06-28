package org.farmcode.validation.validators
{
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.display.validation.ValidationFlag;
	
	public class AbstractValidator implements IValidator
	{
		public function get errorDetails():Array{
			return null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get validChanged():IAct{
			if(!_validChanged)_validChanged = new Act();
			return _validChanged;
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
		
		private var _invalidationPending:Boolean;
		private var _lazyInvalidation:Boolean = false;
		protected var _validChanged:Act;
		private var _valid:Boolean = true;
		
		public function AbstractValidator(lazyInvalidation:Boolean=false){
			this.lazyInvalidation = lazyInvalidation;
		}
		public function getValid(forceCheck:Boolean):Boolean{
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
		protected function invalidate():void{
			checkValid();
		}
		protected function checkValid():void{
			// override, call setValidity()
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