package org.tbyrne.input.items
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.collections.linkedList.LinkedList;
	import org.tbyrne.data.core.StringData;
	import org.tbyrne.data.dataTypes.IDataProvider;
	import org.tbyrne.data.dataTypes.IStringProvider;
	import org.tbyrne.input.menu.IMenuInputItem;

	public class InputGroup extends StringData implements IDataProvider, IMenuInputItem
	{
		/**
		 * @inheritDoc
		 */
		public function get shownInMenuChanged():IAct{
			return (_shownInMenuChanged || (_shownInMenuChanged = new Act()));
		}
		/**
		 * @inheritDoc
		 */
		public function get menuLocationChanged():IAct{
			return (_menuLocationChanged || (_menuLocationChanged = new Act()));
		}
		
		protected var _menuLocationChanged:Act;
		protected var _shownInMenuChanged:Act;
		
		
		
		public function get data():*{
			if(_children && _children.length){
				return _children;
			}else{
				return null;
			}
		}
		public function get childList():LinkedList{
			if(!_children)_children = new LinkedList();
			return _children;
		}
		
		public function get shownInMenu():Boolean{
			return _shownInMenu;
		}
		public function set shownInMenu(value:Boolean):void{
			if(_shownInMenu!=value){
				_shownInMenu = value;
				if(_shownInMenuChanged)_shownInMenuChanged.perform(this);
			}
		}
		public function get menuLocation():String{
			return _menuLocation;
		}
		public function set menuLocation(value:String):void{
			if(_menuLocation!=value){
				_menuLocation = value;
				if(_menuLocationChanged)_menuLocationChanged.perform(this);
			}
		}
		
		private var _menuLocation:String;
		private var _shownInMenu:Boolean = true;
		private var _children:LinkedList;
		
		
		public function InputGroup(stringValue:String=null, children:Array=null){
			super(stringValue);
			if(children){
				addChildren(children);
			}
		}
		public function addChild(child:IStringProvider):void{
			if(child){
				if(!_children)_children = new LinkedList();
				_children.push(child);
			}else{
				Log.log(Log.SUSPICIOUS_IMPLEMENTATION, "NavGroup.addChild: must be provided a IStringProvider argument");
			}
		}
		public function removeChild(child:IStringProvider):void{
			if(child){
				if(!_children)Log.log(Log.SUSPICIOUS_IMPLEMENTATION, "NavGroup.removeChild: child must first be added to NavGroup");
				else{
					_children.removeFirst(child);
				}
			}else{
				Log.log(Log.SUSPICIOUS_IMPLEMENTATION, "NavGroup.removeChild: must be provided a IStringProvider argument");
			}
		}
		public function setChildren(children:Array):void{
			if(_children)_children.reset();
			addChildren(children);
		}
		public function addChildren(children:Array):void{
			for each(var child:IStringProvider in children){
				addChild(child);
			}
		}
		public function removeChildren(children:Array):void{
			for each(var child:IStringProvider in children){
				removeChild(child);
			}
		}
		public function removeAllChildren():void{
			if(_children)_children.reset();
		}
	}
}