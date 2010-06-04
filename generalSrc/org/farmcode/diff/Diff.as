/**
 * Based on the Hunt-McIlroy Algorithm.
 * Ported from:
 * http://www.lshift.net/blog/wp-content/uploads/2006/08/hunt-mcilroy.js
 */
package org.farmcode.diff
{
	import flash.utils.Dictionary;
	

	public class Diff
	{
		private static const CHAR_SPLIT:String = "";
		private static const WORD_SPLIT:RegExp = /(\W)/g;
		private static const LINE_SPLIT:RegExp = /(\r|\n)/g;
		
		public static function executeByCharacter(string1:String, string2:String):Array{
			return execute(string1.split(CHAR_SPLIT),string2.split(CHAR_SPLIT));
		}
		public static function executeByWord(string1:String, string2:String):Array{
			return execute(string1.split(WORD_SPLIT),string2.split(WORD_SPLIT));
		}
		public static function executeByLine(string1:String, string2:String):Array{
			return execute(string1.split(LINE_SPLIT),string2.split(LINE_SPLIT));
		}
		public static function execute(array1:Array, array2:Array):Array{
			
			var equivalenceClasses:Dictionary = new Dictionary();
			var fragment:*;
			for (var j:int = 0; j < array2.length; j++) {
				fragment = array2[j];
				if (equivalenceClasses[fragment]) {
					equivalenceClasses[fragment].push(j);
				} else {
					equivalenceClasses[fragment] = [j];
				}
			}
			
			var candidates:Array = [new Candidate(-1,-1,null)];
			
			for (var i:int = 0; i < array1.length; i++) {
				fragment = array1[i];
				var array2Indices:Array = equivalenceClasses[fragment] || [];
				
				var r:int = 0;
				var c:Candidate = candidates[0];
				
				for (var jX:int = 0; jX < array2Indices.length; jX++) {
					j = array2Indices[jX];
					
					for (var s:int = 0; s < candidates.length; s++) {
						if ((candidates[s].array2Index < j) &&
							((s == candidates.length - 1) ||
								(candidates[s + 1].array2Index > j)))
							break;
					}
					
					if (s < candidates.length) {
						var newCandidate:Candidate = new Candidate(i,j,candidates[s]);
						if (r == candidates.length) {
							candidates.push(c);
						} else {
							candidates[r] = c;
						}
						r = s + 1;
						c = newCandidate;
						if (r == candidates.length) {
							break; // no point in examining further (j)s
						}
					}
				}
				
				candidates[r] = c;
			}
			
			// At this point, we know the LCS: it's in the reverse of the
			// linked-list through .chain of
			// candidates[candidates.length - 1].
			
			// We now apply the LCS to build a "comm"-style picture of the
			// differences between array1 and array2.
			
			var result:Array = [];
			var tail1:int = array1.length;
			var tail2:int = array2.length;
			var common:Common = new Common();
			
			for (var candidate:Candidate = candidates[candidates.length - 1]; candidate != null; candidate = candidate.chain) {
				var different:Difference = new Difference();
				
				while (--tail1 > candidate.array1Index) {
					different.file1.push(array1[tail1]);
				}
				
				while (--tail2 > candidate.array2Index) {
					different.file2.push(array2[tail2]);
				}
				
				if (different.file1.length || different.file2.length) {
					if (common.common.length) {
						common.common.reverse();
						result.push(common);
						common = new Common();
					}
					different.file1.reverse();
					different.file2.reverse();
					result.push(different);
				}
				
				if (tail1 >= 0) {
					common.common.push(array1[tail1]);
				}
			}
			
			if (common.common.length) {
				common.common.reverse();
				result.push(common);
			}
			
			result.reverse();
			return result;
		}
		
	}
}
class Candidate{
	public var array1Index:int;
	public var array2Index:int;
	public var chain:Candidate;
	
	public function Candidate(array1Index:int, array2Index:int, chain:Candidate){
		this.array1Index = array1Index;
		this.array2Index = array2Index;
		this.chain = chain;
	}
}