package org.tbyrne.display.tabFocus
{
	import flash.display.InteractiveObject;
	import flash.events.Event;
	
	import org.tbyrne.core.DelayedCall;
	import org.tbyrne.display.validation.ValidationFlag;

	public class TabFocusGroup extends AbstractTabFocusable implements ITabFocusable
	{
		override public function set tabIndex(value:int):void{
			if(_tabIndex != value){
				_tabIndex = value;
				
				var wasGroup:Boolean = _isChildGroup;
				_isChildGroup = (_tabEnabled && _tabIndex!=-1);
				if(wasGroup!=_isChildGroup){
					_tabIndicesFlag.invalidate();
					if(!focused)_tabIndicesFlag.validate();
				}
			}
		}
		override public function set tabEnabled(value:Boolean):void{
			if(_tabEnabled!=value){
				_tabEnabled = value;
				
				var wasGroup:Boolean = _isChildGroup;
				_isChildGroup = (_tabEnabled && _tabIndex!=-1);
				if(wasGroup!=_isChildGroup){
					_tabIndicesFlag.invalidate();
					if(!focused)_tabIndicesFlag.validate();
				}
			}
		}
		override public function get tabIndicesRequired():uint{
			_tabCountFlag.validate();
			return _tabCount;
		}
		override public function get focused():Boolean{
			return _focused;
		}
		override public function set focused(value:Boolean):void{
			if(_focused!=value){
				_focused = value;
				_tabIndicesFlag.validate(true);
				if(value){
					if(_focusIn)_focusIn.perform(this);
				}else if(_focusOut){
					_focusOut.perform(this);
				}
			}
		}
		public function get items():Array{
			return _rawElements.concat();
		}
		public function set items(value:Array):void{
			var item:*;
			var i:int=0;
			while(i<_rawElements.length){
				item = _rawElements[i];
				if(value.indexOf(item)==-1){
					_removeItem(i);
				}else{
					i++;
				}
			}
			if(value){
				for(i=0; i<value.length; i++){
					item = value[i];
					if(_rawElements.indexOf(item)==-1){
						var tabFocusable:ITabFocusable = (item as ITabFocusable);
						if(tabFocusable){
							addTabFocusable(tabFocusable,i);
						}else{
							var interactiveObject:InteractiveObject = (item as InteractiveObject);
							if(interactiveObject){
								addInteractiveObject(interactiveObject,i);
							}else{
								throw new Error("Can't add item of type "+item.constructor+" to TabFocusGroup");
							}
						}
					}else{
						setItemIndex(item,i);
					}
				}
			}
		}
		
		protected function get isChildGroup():Boolean{
			return _isChildGroup;
		}
		
		private var _tabCount:uint;
		private var _tabIndicesFlag:ValidationFlag;
		private var _tabCountFlag:ValidationFlag;
		
		private var _focused:Boolean;
		private var _tabIndex:int;
		private var _tabEnabled:Boolean;
		private var _isChildGroup:Boolean;
		
		private var _rawElements:Array = [];
		private var _tabFocusableElements:Array = [];
		private var _focusedItem:ITabFocusable;
		
		private var _doFocusOutCall:DelayedCall;
		
		public function TabFocusGroup(items:Array=null){
			_tabIndicesFlag = new ValidationFlag(validateTabIndices,false);
			_tabCountFlag = new ValidationFlag(validateTabCount,false);
			this.items = items;
		}
		public function addInteractiveObject(interactiveObject:InteractiveObject, index:uint=uint.MAX_VALUE):void{
			if(!containsItem(interactiveObject)){
				if(index>_rawElements.length)index = _rawElements.length;
				_rawElements.splice(index,0,interactiveObject);
				_addTabFocusable(new InteractiveObjectFocusWrapper(interactiveObject),index);
			}else{
				throw new Error("This InteractiveObject has already been added to this TabFocusGroup");
			}
		}
		public function addTabFocusable(tabFocusable:ITabFocusable, index:uint=uint.MAX_VALUE):void{
			if(!containsItem(tabFocusable)){
				if(index>_rawElements.length)index = _rawElements.length;
				_rawElements.splice(index,0,tabFocusable);
				_addTabFocusable(tabFocusable,index);
			}else{
				throw new Error("This ITabFocusable has already been added to this TabFocusGroup");
			}
		}
		public function removeItem(item:*):void{
			var currentIndex:int = _rawElements.indexOf(item);
			if(currentIndex!=-1){
				_removeItem(currentIndex);
			}else{
				throw new Error("This item has not been added to this TabFocusGroup");
			}
		}
		public function removeItemAt(index:uint):void{
			if(index<=_rawElements.length){
				_removeItem(index);
			}else{
				throw new RangeError("This index is out of range");
			}
		}
		public function containsItem(item:*):Boolean{
			return _rawElements.indexOf(item)!=-1;
		}
		public function setItemIndex(item:*, index:int):void{
			var currentIndex:int = _rawElements.indexOf(item);
			if(currentIndex!=-1){
				if(index>_rawElements.length)index = _rawElements.length-1;
				_rawElements.splice(currentIndex,1);
				_rawElements.splice(index,0,item);
				var tabFocusable:ITabFocusable = _tabFocusableElements.splice(currentIndex,1)[0];
				_tabFocusableElements.splice(index,0,tabFocusable);
			}else{
				throw new Error("This has not been added to this TabFocusGroup");
			}
		}
		
		
		public function _addTabFocusable(tabFocusable:ITabFocusable, index:uint):void{
			tabFocusable.focusIn.addHandler(onFocusIn);
			tabFocusable.focusOut.addHandler(onFocusOut);
			_tabFocusableElements.splice(index,0,tabFocusable);
			_tabIndicesFlag.invalidate();
			_tabCountFlag.invalidate();
			if(focused || isChildGroup){
				_tabIndicesFlag.validate();
			}else if(tabFocusable.focused){
				_focusedItem = tabFocusable;
				focused = true;
			}else{
				clearTabFocusable(tabFocusable);
			}
		}
		public function _removeItem(index:uint):void{
			_rawElements.splice(index,1);
			var tabFocusable:ITabFocusable = _tabFocusableElements.splice(index,1)[0];
			tabFocusable.focusIn.removeHandler(onFocusIn);
			tabFocusable.focusOut.removeHandler(onFocusOut);
			clearTabFocusable(tabFocusable);
			_tabIndicesFlag.invalidate();
			_tabCountFlag.invalidate();
			if(_focused || isChildGroup){
				if(_focusedItem==tabFocusable){
					_focusedItem = null;
				}
				_tabIndicesFlag.validate();
			}
		}
		protected function onFocusIn(from:ITabFocusable):void{
			if(_doFocusOutCall){
				_doFocusOutCall.clear();
				_doFocusOutCall = null;
			}
			_focusedItem = from;
			focused = true;
		}
		protected function onFocusOut(from:ITabFocusable):void{
			if(focused){
				_doFocusOutCall = new DelayedCall(commitFocusOut,1,false);
				_doFocusOutCall.begin();
			}
		}
		protected function commitFocusOut():void{
			focused = false;
		}
		protected function validateTabCount():void{
			_tabCount = 0;
			for each(var tabFocusable:ITabFocusable in _tabFocusableElements){
				_tabCount += tabFocusable.tabIndicesRequired;
			}
		}
		protected function validateTabIndices():void{
			var tabFocusable:ITabFocusable;
			if(focused || isChildGroup){
				var offset:int = (isChildGroup?0:_tabIndex);
				_tabCount = 0;
				if(focused && !_focusedItem){
					_focusedItem = _tabFocusableElements[0];
				}
				for each(tabFocusable in _tabFocusableElements){
					tabFocusable.tabIndex = offset+_tabCount;
					tabFocusable.tabEnabled = true;
					var focus:Boolean = (_focusedItem == tabFocusable);
					if(focus!=tabFocusable.focused){
						tabFocusable.focused = focus;
					}
					_tabCount += tabFocusable.tabIndicesRequired;
				}
			}else{
				for each(tabFocusable in _tabFocusableElements){
					clearTabFocusable(tabFocusable);
				}
				_focusedItem = null;
			}
		}
		protected function clearTabFocusable(tabFocusable:ITabFocusable):void{
			if(tabFocusable.focused)tabFocusable.focused = false;
			tabFocusable.tabIndex = -1;
			tabFocusable.tabEnabled = false;
		}
	}
}