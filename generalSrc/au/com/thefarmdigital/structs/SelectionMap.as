package au.com.thefarmdigital.structs
{
	public class SelectionMap{
		public function isSelected(index:int):Boolean{
			var ret:Boolean = (selected[index] as Boolean);
			return ret;
		}
		public function setSelected(index:int,selected:Boolean, addAsCulprit:Boolean=true):void{
			var prevIndex:int = culprits.indexOf(index);
			if(prevIndex!=-1)culprits.splice(prevIndex,1);
			
			if(addAsCulprit)culprits.push(index);
			this.selected[index] = selected;
		}
		public function setAllSelected(indices:Array, addAsCulprit:Boolean=true):void{
			var maxIndex:Number = selected.length;
			var length:int = indices.length;
			for(var i:int=0; i<length; ++i){
				maxIndex = Math.max(maxIndex,indices[i]+1);
			}
			for(i=0; i<maxIndex; ++i){
				var value:Boolean = (indices.indexOf(i)!=-1);
				setSelected(i,value,value && addAsCulprit);
			}
		}
		public function getAllSelected():Array{
			var ret:Array = [];
			var length:int = selected.length;
			for(var i:int=0; i<length; ++i){
				if(selected[i]==true){
					ret.push(i);
				}
			}
			return ret;
		}
		public function getSelectedCount():int{
			var ret:int = 0;
			var length:int = selected.length;
			for(var i:int=0; i<length; ++i){
				if(selected[i])ret++;
			}
			return ret;
		}
		public function getLastCulpritIndex():int{
			return (culprits.length?culprits[culprits.length-1]:-1);
		}
		public function getFirstCulprit():int{
			return (culprits.length?culprits.shift():-1);
		}
		
		private var selected:Array = [];
		private var culprits:Array = [];
	}
}