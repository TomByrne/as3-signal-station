package org.farmcode.display.layout.list
{
	import org.farmcode.display.layout.core.MarginLayoutInfo;
	
	public class ListLayoutInfo implements IListLayoutInfo
	{
		public function get listIndex():int{
			return _listIndex;
		}
		public function set listIndex(value:int):void{
			_listIndex = value;
		}
		
		private var _listIndex:int;
		
		public function ListLayoutInfo(listIndex:int=0){
			this.listIndex = listIndex;
		}
	}
}