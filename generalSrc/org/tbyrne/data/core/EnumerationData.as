package org.tbyrne.data.core
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.collections.ICollection;
	import org.tbyrne.collections.IIterator;
	import org.tbyrne.collections.linkedList.LinkedListConverter;
	import org.tbyrne.data.dataTypes.IBooleanConsumer;
	import org.tbyrne.data.dataTypes.IBooleanProvider;
	import org.tbyrne.data.dataTypes.IValueConsumer;
	import org.tbyrne.data.dataTypes.IValueProvider;
	
	public class EnumerationData implements IValueProvider, IValueConsumer, ICollection
	{
		
		public function get options():*{
			return _options;
		}
		public function set options(value:*):void{
			if(_options!=value){
				var iterator:IIterator;
				var current:*;
				var provider:IBooleanProvider;
				
				if(_optionsCollection){
					_optionsCollection.collectionChanged.removeHandler(onCollectionChanged);
					iterator = _optionsCollection.getIterator();
					
					while(current = iterator.next()){
						provider = (current as IBooleanProvider);
						if(provider){
							provider.booleanValueChanged.removeHandler(onSelectionChanged);
						}
					}
					iterator.release();
				}
				_options = value;
				var total:int = 0;
				if(value){
					_optionsCollection = (value as ICollection);
					if(!_optionsCollection){
						_optionsCollection = LinkedListConverter.fromNativeCollection(value);
					}
					if(_optionsCollection){
						_optionsCollection.collectionChanged.addHandler(onCollectionChanged);
						iterator = _optionsCollection.getIterator();
						var found:Boolean;
						
						while(current = iterator.next()){
							provider = (current as IBooleanProvider);
							if(provider){
								if(!found && provider.booleanValue){
									setSelectedOption(provider);
									found = true;
								}
								provider.booleanValueChanged.addHandler(onSelectionChanged);
							}
						}
						iterator.release();
						total = iterator.x;
					}else{
						setSelectedOption(null);
					}
				}else{
					_optionsCollection = null;
					setSelectedOption(null);
				}
				if(_collectionChanged)_collectionChanged.perform(this,0,total);
			}
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get collectionChanged():IAct{
			if(!_collectionChanged)_collectionChanged = new Act();
			return _collectionChanged;
		}
		
		
		
		public function get value():*{
			if(_selectedOptionValueProvider){
				return _selectedOptionValueProvider.value;
			}else{
				return null;
			}
		}
		public function set value(value:*):void{
			if(_optionsCollection){
				var iterator:IIterator = _optionsCollection.getIterator();
				var current:*;
				var provider:IValueProvider;
				
				while(current = iterator.next()){
					provider = (current as IValueProvider);
					if(provider && provider.value==value){
						setSelectedOption(current);
						break;
					}
				}
				iterator.release();
			}
		}
		
		public var allowNullSelection:Boolean = true;
		
		
		/**
		 * @inheritDoc
		 */
		public function get valueChanged():IAct{
			if(!_valueChanged)_valueChanged = new Act();
			return _valueChanged;
		}
		
		protected var _collectionChanged:Act;
		protected var _valueChanged:Act;
		private var _selectedOption:*;
		private var _selectedOptionValueProvider:IValueProvider;
		private var _options:*;
		private var _optionsCollection:ICollection;
		private var _ignoreChanges:Boolean;
		
		public function EnumerationData(options:*=null){
			this.options = options;
		}
		
		protected function onCollectionChanged(from:ICollection, fromX:Number, toX:Number):void{
			if(_collectionChanged)_collectionChanged.perform(this,fromX,toX);
		}
		public function getIterator():IIterator{
			return _optionsCollection?_optionsCollection.getIterator():null;
		}
		protected function setSelectedOption(value:*):void{
			if(_optionsCollection){
				var consumer:IBooleanConsumer;
				if(allowNullSelection || value!=null){
					var iterator:IIterator = _optionsCollection.getIterator();
					var current:*;
					var found:Boolean;
					
					_ignoreChanges = true;
					if(value){
						(value as IBooleanConsumer).booleanValue = true;
					}
					while(current = iterator.next()){
						consumer = (current as IBooleanConsumer);
						if(current!=value){
							consumer.booleanValue = false;
						}else{
							found = true;
						}
					}
					iterator.release();
					_ignoreChanges = false;
					
					if(!found)value = null;
					if(_selectedOption!=value){
						if(_selectedOptionValueProvider){
							_selectedOptionValueProvider.valueChanged.removeHandler(onValueChanged);
						}
						_selectedOption = value;
						if(_selectedOption){
							_selectedOptionValueProvider = (_selectedOption as IValueProvider);
							if(_selectedOptionValueProvider){
								_selectedOptionValueProvider.valueChanged.addHandler(onValueChanged);
							}
							if(_valueChanged)_valueChanged.perform(this);
						}
					}
				}else if(_selectedOptionValueProvider){
					consumer = (_selectedOptionValueProvider as IBooleanConsumer)
					if(consumer)consumer.booleanValue = true;
				}
			}
		}
		protected function onSelectionChanged(from:IBooleanProvider):void{
			if(!_ignoreChanges){
				if(from.booleanValue){
					if(_selectedOption!=from){
						setSelectedOption(from);
					}
				}else if(_selectedOption==from){
					setSelectedOption(null);
				}
			}
		}
		protected function onValueChanged(from:IValueProvider):void{
			if(!_ignoreChanges && _valueChanged)_valueChanged.perform(this);
		}
	}
}