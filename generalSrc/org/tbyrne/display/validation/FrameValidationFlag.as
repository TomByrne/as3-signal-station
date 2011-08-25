package org.tbyrne.display.validation
{
	/** FrameValidationFlag builds on ValidationFlag by making it
	 * validate onEnterFrame. FrameValidationFlags are placed into
	 * a heirarchy based on their scope property. When a 
	 * FrameValidationFlag gets validated (or forced to validate)
	 * it's children too get validated (if they're invalid).
	 */
	
	
	public class FrameValidationFlag extends ValidationFlag implements IFrameValidationFlag
	{
		protected var _added:Boolean;
		protected var _manager:FrameValidationManager;
		
		
		public function FrameValidationFlag(validator:Function, valid:Boolean, parameters:Array=null, readyChecker:Function=null){
			super(validator, valid, parameters, readyChecker);
		}
		protected function setAdded(value:Boolean):void{
			if(_added!=value){
				_added = value;
				if(value){
					_manager.addFrameValFlag(this);
				}else{
					_manager.removeFrameValFlag(this);
				}
			}
		}
		override public function validate(force:Boolean=false):void{
			if(force || !_valid){
				if(_valid)invalidate();
				if(_added)_manager.validate(this);
			}
		}
		public function execute():void{
			_valid = true;
			_executing = true;
			if(parameters)_validator.apply(null,parameters);
			else _validator();
			_executing = false;
		}
		
		/**
		 * override these
		 */
		public function isDescendant(child:IFrameValidationFlag):Boolean{
			return false;
		}
		public function get hierarchyKey():*{
			return -1; // will put them all in the same bundle
		}
	}
}