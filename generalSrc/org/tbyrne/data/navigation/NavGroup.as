package org.tbyrne.data.navigation
{
	import org.tbyrne.collections.linkedList.LinkedList;
	import org.tbyrne.data.core.StringData;
	import org.tbyrne.data.dataTypes.IDataProvider;
	import org.tbyrne.data.dataTypes.IStringProvider;
	import org.tbyrne.debug.logging.Log;

	public class NavGroup extends StringData implements IDataProvider
	{
		public function get data():*{
			if(_children && _children.length){
				return _children;
			}else{
				return null;
			}
		}
		
		private var _children:LinkedList;
		
		
		public function NavGroup(stringValue:String=null, children:Array=null){
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