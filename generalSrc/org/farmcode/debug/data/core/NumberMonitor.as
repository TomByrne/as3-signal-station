package org.farmcode.debug.data.core
{
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.core.EnterFrameHook;
	import org.farmcode.data.dataTypes.INumberProvider;
	import org.farmcode.data.dataTypes.IStringProvider;
	import org.farmcode.formatters.IFormatter;
	
	public class NumberMonitor implements INumberProvider
	{
		/**
		 * @inheritDoc
		 */
		public function get numericalValueChanged():IAct{
			if(!_numericalValueChanged)_numericalValueChanged = new Act();
			return _numericalValueChanged;
		}
		public function get numericalValue():Number{
			return _numericalValue;
		}
		/**
		 * @inheritDoc
		 */
		public function get valueChanged():IAct{
			return numericalValueChanged;
		}
		public function get value():*{
			return numericalValue;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get stringValueChanged():IAct{
			if(!_stringValueChanged)_stringValueChanged = new Act();
			return _stringValueChanged;
		}
		public function get stringValue():String{
			return _stringValue;
		}
		
		
		
		public function get target():Object{
			return _target;
		}
		public function set target(value:Object):void{
			if(_target!=value){
				_target = value;
				checkListening();
			}
		}
		
		public function get prop():String{
			return _prop;
		}
		public function set prop(value:String):void{
			if(_prop!=value){
				_prop = value;
				checkListening();
			}
		}
		
		public function get stringFormatter():IFormatter{
			return _stringFormatter;
		}
		public function set stringFormatter(value:IFormatter):void{
			if(_stringFormatter!=value){
				if(_stringFormatter){
					_stringFormatter.valueProvider = null;
					_stringFormatter.stringValueChanged.removeHandler(onStringValueChanged);
				}
				_stringFormatter = value;
				if(_stringFormatter){
					_stringFormatter.valueProvider = this;
					_stringFormatter.stringValueChanged.addHandler(onStringValueChanged);
				}
			}
		}
		
		private var _stringValue:String;
		private var _stringFormatter:IFormatter;
		protected var _stringValueChanged:Act;
		protected var _numericalValueChanged:Act;
		private var _numericalValue:Number;
		private var _prop:String;
		private var _target:Object;
		private var _listening:Boolean;
		
		public function NumberMonitor(target:Object=null, prop:String=null){
			this.target = target;
			this.prop = prop;
		}
		
		protected function checkListening():void{
			if(_target && _prop){
				if(!_listening){
					_listening = true;
					EnterFrameHook.getAct().addHandler(onEnterFrame);
				}
			}else if(_listening){
				_listening = false;
				EnterFrameHook.getAct().removeHandler(onEnterFrame);
			}
		}
		protected function onEnterFrame():void{
			var newVal:Number = _target[_prop];
			if(_numericalValue!=newVal){
				_numericalValue = newVal;
				if(_numericalValueChanged)_numericalValueChanged.perform(this);
				if(!_stringFormatter){
					_stringValue = String(newVal);
					if(_stringValueChanged)_stringValueChanged.perform(this);
				}
			}
		}
		protected function onStringValueChanged(from:IStringProvider):void{
			_stringValue = _stringFormatter.stringValue;
			if(_stringValueChanged)_stringValueChanged.perform(this);
		}
	}
}