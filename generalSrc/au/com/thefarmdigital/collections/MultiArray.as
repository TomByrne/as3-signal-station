package au.com.thefarmdigital.collections
{
	/**
	 * This class creates a Multidimensional array of the amount of dimensions specified in the constructor.
	 * After construction the amount of dimensions is unchangable.
	 * The set and get methods provide access to elements using an array of numbers, each referencing a dimension as the indexer.
	 */
	public class MultiArray
	{
		public function get dimensions():Number{
			return _dimensions;
		}
		
		private var _dimensions:Number;
		private var root:Array;
		
		public function MultiArray(dimensions:Number){
			_dimensions = dimensions;
			root = [];
		}
		public function clone():MultiArray{
			var ret:MultiArray = new MultiArray(_dimensions);
			_clone(ret,root,[]);
			return ret;
		}
		protected function _clone(subject:MultiArray,array:Array,coOrds:Array,gen:Number=0):void{
			var length:int;
			if(gen<_dimensions-1){
				length = array.length;
				for(var i:int=0; i<length; ++i){
					var newCoOrds:Array = coOrds.concat(i);
					var nextArray:Array = array[i];
					if(nextArray){
						_clone(subject,nextArray,newCoOrds,gen+1);
					}
				}
			}else{
				length = array.length;
				for(i=0; i<length; ++i){
					newCoOrds = coOrds.concat(i);
					var item:* = array[i];
					subject.set(newCoOrds,item);
				}
			}
		}
		public function getLength(dimension:Number):Number{
			var length:int;
			if(dimension>_dimensions)return NaN;
			var arrays:Array = [root];
			for(var i:uint=0; i<dimension; ++i){
				var newArrays:Array = [];
				length = arrays.length;
				for(var j:uint=0; j<length; ++j){
					newArrays = newArrays.concat(arrays[j]);
				}
				arrays =  newArrays;
			}
			var maxLength:Number = 0;
			length = arrays.length;
			for(i=0; i<length; ++i){
				var array:Array = arrays[i];
				if(array)maxLength = Math.max(maxLength,array.length);
			}
			return maxLength;
		}
		public function get(indices:Array):*{
			if(indices.length!=_dimensions)return null;
			var item:* = root;
			for(var i:uint=0; i<_dimensions; ++i){
				item = item[indices[i]];
				if(i==_dimensions-1)return item;
				else if(!item)return null;
			}
		}
		public function set(indices:Array, value:*):void{
			if(indices.length!=_dimensions)return;
			var item:* = root;
			for(var i:uint=0; i<_dimensions; ++i){
				if(i==_dimensions-1){
					item[indices[i]] = value;
					return;
				}else{
					var newItem:Array = item[indices[i]];
					if(!newItem)newItem = item[indices[i]] = [];
					item = newItem;
				}
			}
		}
		public function indicesOf(value:*):Array{
			return _indicesOf(root,value,0,[]);
		}
		private function _indicesOf(within:Array,value:*,dimension:int, indices:Array):Array{
			var length:int = within.length;
			for(var i:int=0; i<length; ++i){
				var child:* = within[i];
				if(child){
					if(dimension==_dimensions-1){
						if(child==value){
							return indices.concat(i);
						}
					}else if(child is Array){
						var ret:Array = _indicesOf(child,value,dimension+1,indices.concat(i));
						if(ret)return ret;
					}
				}
			}
			return null;
		}
	}
}