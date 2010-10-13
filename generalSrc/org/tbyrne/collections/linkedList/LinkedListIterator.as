package org.tbyrne.collections.linkedList
{
	import org.tbyrne.collections.IIterator;
	import org.tbyrne.hoborg.IPoolable;
	import org.tbyrne.hoborg.ObjectPool;
	
	public class LinkedListIterator implements IIterator, IPoolable{
		private static const pool:ObjectPool = new ObjectPool(LinkedListIterator);
		
		public static function getNew():LinkedListIterator{
			return pool.takeObject();
		}
		
		
		[Property(toString="true",clonable="true")]
		public function get firstLink():Link{
			return _firstLink;
		}
		public function set firstLink(value:Link):void{
			_firstLink = value;
		}
		
		private var _firstLink:Link;
		private var currentLink:Link;
		private var begun:Boolean = false;
		private var _x:int = -1;
		
		public function LinkedListIterator(firstLink:Link=null):void{
			_firstLink = firstLink;
		}
		public function next():*{
			if(!begun){
				currentLink = _firstLink;
				begun = true;
				_x = 0;
			}else if(currentLink){
				currentLink = currentLink.next;
				++_x;
			}
			if(currentLink)return currentLink.value;
			return null;
		}
		public function current():*{
			return currentLink?currentLink.value:null;
		}
		public function reset():void{
			_firstLink = null;
			currentLink = null;
			begun = false;
			_x = -1;
		}
		public function release():void{
			pool.releaseObject(this);
		}
		public function get x():int{
			return _x;
		}
	}
}