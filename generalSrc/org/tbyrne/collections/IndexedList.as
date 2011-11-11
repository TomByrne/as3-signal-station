package org.tbyrne.collections
{
	import flash.utils.Dictionary;
	
	// TODO: pooling
	public class IndexedList{
		public function get list():Array{
			return _list;
		}
		
		private var _list:Array = [];
		private var _indices:Dictionary = new Dictionary();
		
		public function add(value:*):void{
			if(_indices[value]==null){
				_indices[value] = _list.length;
				_list.push(value);
			}
		}
		public function remove(value:*):void{
			var index:* = _indices[value];
			if(index!=null){
				delete _indices[value];
				_list.splice(index,1);
				while(index<_list.length){
					_indices[_list[index]] = index;
					++index;
				}
			}
		}
		public function containsItem(value:*):Boolean{
			return (_indices[value]!=null);
		}
		public function clear():void{
			if(_list.length){
				_list = [];
				_indices = new Dictionary();
			}
		}
	}
}