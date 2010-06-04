package au.com.thefarmdigital.utils
{
	public class ArrayUtils
	{
		public static function shuffle(array: Array): Array
		{
			return array.sort(ArrayUtils.randomComparison);
		}
		
		// TODO: Should this be part of a more general set of utils? for comparisons
		public static function randomComparison(element1: *, element2: *): int
		{
			var diff: int = 0;
			var result: Number = Math.random();
			if (result < 0.5)
			{
				diff = 1;
			}
			else if (result > 0.5)
			{
				diff = -1;
			}
			return diff;
		}
		
		// TODO: Implement a flag for whether ordering is important
		// currently doesn't matter about the order
		public static function equals(arr1: Array, arr2: Array): Boolean
		{
			var equal: Boolean = false;
			
			if (arr1 == arr2)
			{
				equal = true;
			}
			else if (arr1 != null && arr2 != null && arr1.length == arr2.length)
			{
				var arr1Check: Array = arr1.slice();
				var missingItem: Boolean = false;
				for (var i: uint = 0; i < arr2.length && !missingItem; ++i)
				{
					var testItem: * = arr2[i];
					var arr1CheckIndex: int = arr1Check.indexOf(testItem);
					if (arr1CheckIndex >= 0)
					{
						arr1Check.splice(arr1CheckIndex, 1);
					}
					else
					{
						missingItem = true;
					}
				}
				if (arr1Check.length == 0)
				{
					equal = true;
				}
			}
			
			return equal;
		}
		
		public static function getSortedIndex(source: Array, item: *, 
			comparisonFunction: Function = null): int
		{
			var targetIndex: int = 0;
			
			if (comparisonFunction == null)
			{
				comparisonFunction = ArrayUtils.compareNumbers;
			}
			var foundBound: Boolean = false;
			for (var i: uint = 0; i < source.length && !foundBound; ++i)
			{
				var testItem: * = source[i];
				
				var diff: int = comparisonFunction(item, testItem); 
				if (diff > 0)
				{
					targetIndex = i + 1;
				}
				else
				{
					foundBound = true;
				}
			}
			
			return targetIndex;
		}
		
		private static function compareNumbers(item1: *, item2: *): int
		{
			var num1: Number = Number(item1);
			var num2: Number = Number(item2);
			var diff: int = 0;
			if (num1 > num2)
			{
				diff = 1;
			}
			else if (num1 < num2)
			{
				diff = -1;
			}
			return diff;
		}
		
		public static function arrayDiff(array1:Array, array2:Array, returnCommon:Boolean = true, equalityFunc:Function=null):Array{
			var length:int;
			if(equalityFunc == null){
				equalityFunc = function(elem1:*, elem2:*):Boolean{
					return elem1==elem2;
				}
			}
			var match1:Array = [];
			var match2:Array = [];
			length = array1.length;
			for(var i:int=0; i<length; ++i){
				var length2:int = array2.length;
				for(var j:int=0; j<length2; ++j){
					if(equalityFunc(array1[i],array2[j])){
						match1.push(i);
						match2.push(j);
					}
				}
			}
			var ret:Array = [];
			if(returnCommon){
				length = match1.length;
				for(i=0; i<length; ++i){
					ret.push(array1[match1[i]]);
				}
			}else{
				var copy:Array = array1.slice();
				i=0;
				var index:Number = 0;
				while(i<copy.length){
					if(match1.indexOf(index)!=-1){
						copy.splice(i,1);
					}else{
						i++;
					}
					index++;
				}
				ret = ret.concat(copy);
				var copy2:Array = array2.slice();
				i=0;
				var index2:Number = 0;
				while(i<copy2.length){
					if(match2.indexOf(index2)!=-1){
						copy2.splice(i,1);
					}else{
						i++;
					}
					index2++;
				}
				ret = ret.concat(copy2);
			}
			return ret;
		}
		
		public static function unique(arr: Array): void
		{
			var alreadyFound: Array = new Array();
			for (var i: uint = 0; i < arr.length; ++i)
			{
				var item: * = arr[i];
				if (alreadyFound.indexOf(item) >= 0)
				{
					arr.splice(i, 1);
					i--;
				}
				else
				{
					alreadyFound.push(item);
				}
			}
		}
		
		public static function toString(arr: Array, itemMaxLength: int = -1): String
		{
			var str: String = "[";
			for (var i: uint = 0; i < arr.length; ++i)
			{
				var item: String = String(arr[i]);
				if (itemMaxLength >= 0)
				{
					str += item.substr(0, itemMaxLength);
				}
				else
				{
					str += item;
				}
				
				if (i < (arr.length - 1))
				{
					str += ", ";
				}
			}
			str += "]";
			return str
		}
	}
}