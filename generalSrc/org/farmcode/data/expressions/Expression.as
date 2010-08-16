package org.farmcode.data.expressions
{
	import flash.utils.Dictionary;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.data.dataTypes.IValueProvider;
	
	public class Expression implements IValueProvider
	{
		public function get value():*{
			return _result;
		}
		/**
		 * @inheritDoc
		 */
		public function get valueChanged():IAct{
			if(!_valueChanged)_valueChanged = new Act();
			return _valueChanged;
		}
		
		protected var _valueChanged:Act;
		private var _listening:Dictionary = new Dictionary();
		private var _result:*;
		
		public function Expression(){
		}
		protected function reevaluate():void{
			// override me
		}
		protected function setResult(result:*):void{
			if(_result != result){
				_result = result;
				if(_valueChanged){
					_valueChanged.perform(this);
				}
			}
		}
		protected function onProviderChanged(from:IValueProvider):void{
			reevaluate();
		}
		protected function clearListeners():void{
			for(var i:* in _listening){
				var valueProv:IValueProvider = i as IValueProvider;
				if(valueProv){
					valueProv.valueChanged.removeHandler(onProviderChanged);
				}
			}
			_listening = new Dictionary();
		}
		protected function listenTo(valueProv:IValueProvider):void{
			if(valueProv && !_listening[valueProv]){
				valueProv.valueChanged.addHandler(onProviderChanged);
				_listening[valueProv] = true;
			}
		}
		protected function stopListening(valueProv:IValueProvider):void{
			if(valueProv && _listening[valueProv]){
				valueProv.valueChanged.removeHandler(onProviderChanged);
				delete _listening[valueProv];
			}
		}
	}
}