package org.tbyrne.data.operators
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.data.dataTypes.IBooleanProvider;
	
	public class BooleanGroup implements IBooleanProvider
	{
		
		public function get booleanValue():Boolean{
			return _booleanValue;
		}
		/**
		 * @inheritDoc
		 */
		public function get booleanValueChanged():IAct{
			return (_booleanValueChanged || (_booleanValueChanged = new Act()));
		}
		
		
		public function get or():Boolean{
			return _or;
		}
		public function set or(value:Boolean):void{
			if(_or!=value){
				_or = value;
				recheck();
			}
		}
		
		private var _or:Boolean;
		
		protected var _booleanValueChanged:Act;
		protected var _booleanValue:Boolean;
		
		protected var _booleanProvs:Vector.<IBooleanProvider>;
		
		
		public function BooleanGroup(or:Boolean=false, booleanProvs:Array=null)
		{
			this.or = or;
			
			_booleanProvs = new Vector.<IBooleanProvider>();
			
			if(booleanProvs){
				for each(var boolProv:IBooleanProvider in booleanProvs){
					addBooleanProvider(boolProv);
				}
			}
		}
		
		public function addBooleanProvider(boolProv:IBooleanProvider):void{
			if(_booleanProvs.indexOf(boolProv)!=-1)return;
			
			boolProv.booleanValueChanged.addHandler(onBoolChanged);
			_booleanProvs.push(boolProv);
			if(_or){
				if(boolProv.booleanValue){
					setBooleanValue(true);
				}
			}else{
				if(!boolProv.booleanValue){
					setBooleanValue(false);
				}
			}
		}
		public function removeBooleanProvider(boolProv:IBooleanProvider):void{
			var index:int = _booleanProvs.indexOf(boolProv);
			if(index!=-1){
				boolProv.booleanValueChanged.removeHandler(onBoolChanged);
				_booleanProvs.splice(index,1);
				if(_or){
					if(_booleanValue && boolProv.booleanValue){
						recheck();
					}
				}else if(!_booleanValue && !boolProv.booleanValue){
					recheck();
				}
			}
		}
		
		
		private function onBoolChanged(from:IBooleanProvider):void
		{
			if(_or){
				if(from.booleanValue){
					setBooleanValue(true);
				}else if(_booleanValue){
					recheck();
				}
			}else if(!from.booleanValue){
				setBooleanValue(false);
			}else if(!_booleanValue){
				recheck();
			}
		}
		
		private function setBooleanValue(value:Boolean):void{
			if(_booleanValue!=value){
				_booleanValue = value;
				if(_booleanValueChanged)_booleanValueChanged.perform(this);
			}
		}		
		
		private function recheck():void{
			for each(var boolProv:IBooleanProvider in _booleanProvs){
				if(boolProv.booleanValue==_or){
					setBooleanValue(_or);
					return;
				}
			}
			setBooleanValue(!_or);
		}
	}
}