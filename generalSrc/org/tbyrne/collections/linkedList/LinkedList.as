package org.tbyrne.collections.linkedList
{
	import flash.utils.Dictionary;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.collections.ICollection;
	import org.tbyrne.collections.IIterator;
	import org.tbyrne.hoborg.IPoolable;
	import org.tbyrne.hoborg.ObjectPool;
	
	public class LinkedList implements IPoolable, ICollection
	{
		private static const pool:ObjectPool = new ObjectPool(LinkedList);
		public static function getNew():LinkedList{
			return pool.takeObject();
		}
		
		protected static var linkPool:Array = []; // can't use ObjectPool class because sometimes a LinkedList becomes a pool for itself
		protected static var iteratorPool:Array = [];
		
		
		/**
		 * @inheritDoc
		 */
		public function get collectionChanged():IAct{
			if(!_collectionChanged)_collectionChanged = new Act();
			return _collectionChanged;
		}
		
		
		public function get length():uint{
			return _length;
		}
		internal function set firstLink(value:Link):void{
			_firstLink = value;
			_length = 0;
			var subj:Link = _firstLink;
			while(subj){
				_indexes[subj.value] = _length;
				_length++;
				subj = subj.next;
			}
		}
		CONFIG::debug{
			/** This is useful for debugging but shouldn't be used elsewhere
			 * as it defeats the purpose of using a LinkedList in the first place.
			 */
			public function get arrayVersion():Array{
				var ret:Array = [];
				var iterator:IIterator = getIterator();
				var child:*;
				while(child = iterator.next()){
					ret.push(child);
				}
				iterator.release();
				return ret;
			}
		}
		
		/**
		 * The only time this should be set to false is for the LinkedLists within
		 * ObjectPools (otherwise the become infinitely recursive).
		 */
		[Property(toString="true",clonable="true")]
		public function get useIteratorPool():Boolean{
			return _useIteratorPool;
		}
		public function set useIteratorPool(value:Boolean):void{
			_useIteratorPool = value;
		}
		
		protected var _collectionChanged:Act;
		private var _useIteratorPool:Boolean = true;
		private var _length:uint = 0;
		private var _firstLink:Link;
		private var _indexes:Dictionary = new Dictionary(true);
		
		public function LinkedList(){
		}
		
		public function get(index:uint):*{
			if(index>_length-1){
				throwIndexError(index);
			}else if(_length>0){
				var subject:Link = _firstLink;
				while(index>0){
					subject = subject.next;
					index--;
				}
				return subject.value;
			}else{
				return null;
			}
		}
		public function set(index:uint, value:*):void{
			if(index>_length){
				throwIndexError(index);
			}else if(index==_length){
				splice(_length,0,[value]);
			}else if(_length>0){
				var subject:Link = _firstLink;
				while(index>0){
					subject = subject.next;
					index--;
				}
				subject.value = value;
				_indexes[value] = index;
				if(_collectionChanged)_collectionChanged.perform(this,index,index+1);
			}
		}
		public function getIterator():IIterator{
			var ret:LinkedListIterator = LinkedListIterator.getNew();
			ret.firstLink = _firstLink;
			return ret;
		}
		public function pop():*{
			var list:LinkedList = splice(_length-1,1);
			var ret:* = list.get(0);
			list.release();
			return ret;
		}
		public function push(value:*):void{
			splice(_length,0,[value]);
		}
		public function shift():*{
			if(_firstLink){
				var link:Link = _firstLink;
				_firstLink = link.next;
				var ret:* = link.value;
				_length--;
				destroyLink(link);
				if(_collectionChanged)_collectionChanged.perform(this,_length,_length+1);
				return ret;
			}else{
				return null;
			}
		}
		public function unshift(value:*):void{
			splice(0,0,[value]);
		}
		public function contains(value:*):Boolean{
			return _indexes[value]!=null;
		}
		public function firstIndexOf(value:*):int{
			var value:* = _indexes[value];
			if(value!=null)return value;
			else return -1;
		}
		public function reset():void{
			var link:Link = _firstLink;
			while(link){
				var next:Link = link.next
				destroyLink(link);
				link = next;
			}
			_firstLink = null;
			_length = 0;
			_indexes = new Dictionary(true);
		}
		public function clone():Object{
			var ret:LinkedList = getNew();
			var iterator:IIterator = getIterator();
			var value:*;
			while((value = iterator.next())!=null){
				ret.push(value);
			}
			iterator.release();
			return ret;
		}
		/**
		 * Removes the first occurance of a value, returns true if the value was found.
		 */
		public function removeFirst(value:*):Boolean{
			var index:* = _indexes[value];
			if(index!=null){
				var before:Link;
				var removeLink:Link = _firstLink;
				var count:uint = index;
				while(count>0){
					before = removeLink;
					removeLink = removeLink.next;
					count--;
				}
				if(index==0){
					_firstLink = removeLink.next;
				}else{
					before.next = removeLink.next;
				}
				destroyLink(removeLink);
				
				incrementIndices(index,-1);
				--_length;
				if(_collectionChanged)_collectionChanged.perform(this,index,_length);
				delete _indexes[value];
				return true;
			}
			return false;
		}
		protected function incrementIndices(from:int, by:int):void{
			var done:Dictionary = new Dictionary();
			for(var i:* in _indexes){
				if(!done[i]){
					done[i] = true;
					var value:int = _indexes[i];
					if(value>=from){
						_indexes[i] = value+by;
					}
				}
			}
		}
		/*protected function checkIndices():void{
			var used:Array = [];
			for(var i:* in _indexes){
				var index:int = _indexes[i];
				if(used.indexOf(index)!=-1){
					used = used;
				}
				if(arrayVersion[index]!=i){
					used = used;
				}
				used.push(index);
			}
		}*/
		public function splice(index:uint, deleteCount:uint, insert:Array=null):LinkedList{
			if(index+deleteCount>_length){
				throwIndexError(index+deleteCount);
			}
			var before:Link;
			var after:Link = _firstLink;
			var count:uint = index;
			while(count>0){
				before = after;
				after = after.next;
				count--;
			}
			var ret:LinkedList;
			var deleted:int = 0;
			if(deleteCount>0){
				ret = getNew();
				var firstDel:Link = after;
				while(deleted<deleteCount){
					delete _indexes[after.value];
					var next:Link = after.next;
					if(++deleted==deleteCount){
						after.next = null;
					}
					_length--;
					after = next;
				}
				if(index==0){
					_firstLink = after;
				}
				ret.firstLink = firstDel;
			}
			var addCount:int = (insert?insert.length:0);
			incrementIndices(index,addCount-deleteCount);
			if(addCount){
				count = 0;
				while(insert.length){
					//var inserted:Link = linkPool.takeObject();
					var inserted:Link = getLink();
					if(before){
						before.next = inserted;
					}else{
						_firstLink = inserted;
					}
					_length++;
					inserted.value = insert.shift();
					before = inserted;
					_indexes[inserted.value] = index+count++;
				}
			}
			if(before){
				before.next = after;
			}
			
			if(_collectionChanged){
				var toX:int;
				if(insert && deleteCount==insert.length){
					toX = index+deleteCount;
				}else{
					toX = _length;
				}
				_collectionChanged.perform(this,index,toX);
			}
			return ret;
		}
		private function throwIndexError(index:uint):void{
			throw new Error("LinkedList: index "+index+" is out of bounds");
		}
		public function release():void{
			pool.releaseObject(this)
		}
		protected function destroyLink(link:Link):void{
			link.next = null;
			link.value = null;
			linkPool.push(link);
		}
		protected function getLink():Link{
			var ret:Link = linkPool.pop();
			if(ret)return ret;
			else return new Link();
		}
	}
}