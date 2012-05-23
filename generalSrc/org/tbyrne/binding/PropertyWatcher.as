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
				if(_bindable && _changeProp){
					_bindable[_changeProp].removeHandler(onValueChanged);
				}
				_bindable = value;
				if(_bindable && _dirProperty){
					_bindable[_changeProp].addHandler(onValueChanged);
					onValueChanged();
				}else{
					setValue(null);
				}
				
			}
		}
		public function get property():String{
			return _property;
		}
		public function set property(value:String):void{
			if(_property!=value){
				if(_changeProp){
					if(_bindable){
						_bindable[_changeProp].removeHandler(onValueChanged);
					}
					_changeProp = null;
				}
				
				_property = value;
				
				
				var index:int = _property?_property.indexOf("."):-1;
				if(index==-1){
					_useChildBinder = false;
					_dirProperty = _property;
					
					if(_childBinder){
						_childBinder.bindable = null;
						_childBinder.setHandler = null;
						_childBinder.updateHandler = null;
						_childBinder.unsetHandler = null;
					}
				}else{
					_useChildBinder = true;
					_dirProperty = property.slice(0,index);
					if(!_childBinder){
						_childBinder = new PropertyWatcher();
					}
					_childBinder.property = property.slice(index+1);
					_childBinder.setHandler = _setHandler;
					_childBinder.updateHandler = _updateHandler;
					_childBinder.unsetHandler = _unsetHandler;
				}
				
				if(_dirProperty){
					_changeProp = _dirProperty+"Changed";
					
					if(_bindable){
						_bindable[_changeProp].addHandler(onValueChanged);
						onValueChanged();
					}
				}else{
					setValue(null);
				}
			}
		}
		
		
		public function get setHandler():Function{
			return _setHandler;
		}
		public function set setHandler(value:Function):void{
			if(_setHandler!=value){
				_setHandler = value;
				if(_useChildBinder){
					_childBinder.setHandler = _setHandler;
				}
			}
		}
		
		public function get updateHandler():Function{
			return _updateHandler;
		}
		public function set updateHandler(value:Function):void{
			if(_updateHandler!=value){
				_updateHandler = value;
				if(_useChildBinder){
					_childBinder.updateHandler = _updateHandler;
				}
			}
		}
		
		public function get unsetHandler():Function{
			return _unsetHandler;
		}
		public function set unsetHandler(value:Function):void{
			if(_unsetHandler!=value){
				_unsetHandler = value;
				if(_useChildBinder){
					_childBinder.unsetHandler = _unsetHandler;
				}
			}
		}
		
		private var _value:*;
		private var _valueSet:Boolean;
		
		private var _bindable:Object;
		private var _property:String;
		private var _dirProperty:String;
		private var _changeProp:String;
		private var _useChildBinder:Boolean;
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
		public function PropertyWatcher(property:String=null, setHandler:Function=null, updateHandler:Function=null, unsetHandler:Function=null, bindable:Object=null){
			
			this.setHandler = setHandler;
			this.updateHandler = updateHandler;
			this.unsetHandler = unsetHandler;
			
			this.property = property;
			this.bindable = bindable;
		}
		protected function onValueChanged(... params):void{
			setValue(_bindable[_dirProperty]);
		}
		protected function setValue(value:*):void{
			var newValueSet:Boolean = (value!=null);
			var oldValue:* = _value;
			_value = value;
			
			var setHandler:Function;
			var updateHandler:Function;
			var unsetHandler:Function;
			if(_useChildBinder){
				setHandler = setChildBindable;
			}else{
				setHandler = _setHandler;
				updateHandler = _updateHandler;
				unsetHandler = _unsetHandler;
			}
			
			if(newValueSet){
				if(_valueSet){
					if(updateHandler!=null)updateHandler(oldValue,value);
					else{
						if(unsetHandler!=null)unsetHandler(oldValue);
						setHandler(value);
					}
				}else{
					if(setHandler!=null)setHandler(value);
					else updateHandler(null,value);
				}
			}else if(_valueSet){
				if(unsetHandler!=null)unsetHandler(oldValue);
				else{
					if(setHandler!=null)setHandler(value);
					else updateHandler(null,value);
				}
			}
			_valueSet = newValueSet;
		}
		protected function setChildBindable(value:*):void{
			_childBinder.bindable = value;
		}
		
		public function clear():void{
			if(_childBinder)_childBinder.clear();
			
			property = null;
			bindable = null;
		}
	}
}