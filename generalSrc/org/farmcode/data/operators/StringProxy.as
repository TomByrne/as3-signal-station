package org.farmcode.data.operators
{
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.data.dataTypes.IStringConsumer;
	import org.farmcode.data.dataTypes.IStringProvider;
	
	public class StringProxy implements IStringConsumer, IStringProvider
	{
		
		/**
		 * @inheritDocs
		 */
		public function get stringValueChanged():IAct{
			if(!_stringValueChanged)_stringValueChanged = new Act();
			return _stringValueChanged;
		}
		/**
		 * @inheritDocs
		 */
		public function get valueChanged():IAct{
			return stringValueChanged;
		}
		
		
		public function get stringProvider():IStringProvider{
			return _stringProvider;
		}
		public function set stringProvider(value:IStringProvider):void{
			if(_stringProvider!=value){
				if(_stringProvider){
					_stringProvider.stringValueChanged.removeHandler(onStringChanged);
				}
				_stringProvider = value;
				_stringConsumer = (value as IStringConsumer);
				if(_stringProvider){
					_stringProvider.stringValueChanged.addHandler(onStringChanged);
				}
				if(_stringValueChanged)_stringValueChanged.perform(this);
			}
		}
		
		public function get stringValue():String{
			return _stringProvider?_stringProvider.stringValue:null;
		}
		public function get value():*{
			return stringValue;
		}
		public function set stringValue(value:String):void{
			_stringConsumer.stringValue = value;
		}
		
		private var _stringProvider:IStringProvider;
		private var _stringConsumer:IStringConsumer;
		protected var _stringValueChanged:Act;
		
		public function StringProxy(stringProvider:IStringProvider=null){
			this.stringProvider = stringProvider;
		}
		protected function onStringChanged(from:IStringProvider):void{
			if(_stringValueChanged)_stringValueChanged.perform(this);
		}
	}
}