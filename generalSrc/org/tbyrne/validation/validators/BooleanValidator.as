package org.tbyrne.validation.validators
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.data.dataTypes.IBooleanProvider;
	import org.tbyrne.validation.IErrorDetails;
	
	public class BooleanValidator extends AbstractValidator
	{
		public function get booleanProvider():IBooleanProvider{
			return _booleanProvider;
		}
		public function set booleanProvider(value:IBooleanProvider):void{
			if(_booleanProvider!=value){
				if(_booleanProvider){
					_booleanProvider.booleanValueChanged.removeHandler(onBooleanChanged);
				}
				_booleanProvider = value;
				if(_booleanProvider){
					_booleanProvider.booleanValueChanged.addHandler(onBooleanChanged);
				}
				invalidate();
			}
		}
		
		public function get matchTrue():Boolean{
			return _matchTrue;
		}
		public function set matchTrue(value:Boolean):void{
			if(_matchTrue!=value){
				_matchTrue = value;
				invalidate();
			}
		}
		
		override public function get errorDetails():Array{
			return _errorDetails;
		}
		public function set errorDetails(value:Array):void{
			_errorDetails = value;
		}
		
		private var _errorDetails:Array;
		private var _matchTrue:Boolean = true;
		private var _booleanProvider:IBooleanProvider;
		
		public function BooleanValidator(liveValidation:Boolean=true, booleanProvider:IBooleanProvider=null){
			super(liveValidation);
			this.booleanProvider = booleanProvider;
		}
		public function onBooleanChanged(from:IBooleanProvider):void{
			invalidate();
		}
		override protected function checkValid():void{
			if(_booleanProvider){
				if(_booleanProvider.booleanValue==_matchTrue){
					setValid(true);
				}else{
					setValid(false);
				}
			}
		}
	}
}