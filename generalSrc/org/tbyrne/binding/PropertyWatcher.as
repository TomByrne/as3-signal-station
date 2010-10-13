package org.tbyrne.binding
{
	import org.tbyrne.acting.acts.Act;

	public class PropertyWatcher
	{
		public function get bindable():Object{
			return _bindable;
		}
		public function set bindable(value:Object):void{
			if(_bindable!=value){
				if(_bindable){
					_bindable[_changeProp].removeHandler(onValueChanged);
				}
				_bindable = value;
				if(_bindable){
					_bindable[_changeProp].addHandler(onValueChanged);
					setValue(_bindable[_property]);
				}else{
					setValue(null);
				}
			}
		}
		
		private var _value:*;
		private var _valueSet:Boolean;
		
		private var _bindable:Object;
		private var _property:String;
		private var _changeProp:String;
		private var _childBinder:PropertyWatcher;
		
		private var _setHandler:Function;
		private var _updateHandler:Function;
		private var _unsetHandler:Function;
		
		/**
		 * Watches a property on an object and calls the unsetHandler/setHandlers when required.
		 * 
		 * @param property A property to watch. This can be a nested property using dot notation (e.g
		 * sprite.scrollRect.x) although every property within the chain must have an accompanying
		 * changed IAct object (or be dynamic and extend the Watchable class).
		 * 
		 * @param setHandler The handler to be called when the value is set to a non-null value. This
		 * should have a signature like function(newValue:*):void
		 * 
		 * @param updateHandler The handler to be called when the value is set to a non-null value
		 * from a non-null value. If this is null then unsetHandler will be called (if it's set)
		 * followed by setHandler. This should have a signature like function(oldValue:*, newValue:*):void
		 * 
		 * @param unsetHandler The handler to be called when the value is set to null. This
		 * should have a signature like function(oldValue:*):void
		 * 
		 * @see org.farmcode.binding.Watchable
		 */
		public function PropertyWatcher(property:String, setHandler:Function, updateHandler:Function=null, unsetHandler:Function=null, bindable:Object=null){
			init(property, setHandler, updateHandler, unsetHandler);
			this.bindable = bindable;
		}
		protected function init(property:String, setHandler:Function, updateHandler:Function, unsetHandler:Function):void{
			var index:int = property.indexOf(".");
			if(index==-1){
				_property = property;
				_setHandler = setHandler;
				_updateHandler = updateHandler;
				_unsetHandler = unsetHandler;
			}else{
				_property = property.slice(0,index);
				_childBinder = new PropertyWatcher(property.slice(index+1), setHandler, updateHandler, unsetHandler);
				_setHandler = setChildBindable;
			}
			_changeProp = _property+"Changed";
		}
		protected function onValueChanged(... params):void{
			setValue(_bindable[_property]);
		}
		protected function setValue(value:*):void{
			var newValueSet:Boolean = (value!=null);
			var oldValue:* = _value;
			_value = value;
			
			if(newValueSet){
				if(_valueSet){
					if(_updateHandler!=null)_updateHandler(oldValue,value);
					else{
						if(_unsetHandler!=null)_unsetHandler(oldValue);
						_setHandler(value);
					}
				}else{
					_setHandler(value);
				}
			}else if(_valueSet){
				if(_unsetHandler!=null)_unsetHandler(oldValue);
				else _setHandler(value);
			}
			_valueSet = newValueSet;
		}
		protected function setChildBindable(value:*):void{
			_childBinder.bindable = value;
		}
	}
}