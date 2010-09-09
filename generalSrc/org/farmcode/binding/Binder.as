package org.farmcode.binding
{
	public class Binder
	{
		
		public function get srcBindable():Object{
			return _propWatcher.bindable;
		}
		public function set srcBindable(value:Object):void{
			_propWatcher.bindable = value;
		}
		
		public function get destProperty():String{
			return _destProperty;
		}
		public function set destProperty(value:String):void{
			if(_destProperty!=value){
				checkUnset();
				_destProperty = value;
				checkSet();
			}
		}
		
		public function get destObject():Object{
			return _destObject;
		}
		public function set destObject(value:Object):void{
			if(_destObject!=value){
				checkUnset();
				_destObject = value;
				checkSet();
			}
		}
		
		public var doUnset:Boolean = true;
		
		private var _destObject:Object;
		private var _destProperty:String;
		private var _propWatcher:PropertyWatcher;
		private var _value:*;
		private var _numberMode:Boolean;
		
		public function Binder(destObject:Object=null, destProp:String=null, srcBindable:Object=null, srcProp:String=null){
			_propWatcher = new PropertyWatcher(srcProp,setValue,null,null,srcBindable);
			this.destProperty = destProp;
		}
		protected function setValue(value:*):void{
			_value = value;
			_numberMode = (value is Number);
			checkSet();
		}
		protected function checkUnset():void{
			if(doUnset && _destProperty && _destObject){
				setDestValue(_numberMode?NaN:null);
			}
		}
		protected function checkSet():void{
			if(_destProperty && _destObject){
				setDestValue(_value);
			}
		}
		protected function setDestValue(value:*):void{
			var subject:Object = _destObject;
			var propPath:Array = _destProperty.split(".");
			var propCount:int = propPath.length;
			for(var i:int=0; i<propCount-2; i++){
				subject = subject[propPath[i]];
			}
			subject[propPath[propCount-1]] = value;
		}
	}
}