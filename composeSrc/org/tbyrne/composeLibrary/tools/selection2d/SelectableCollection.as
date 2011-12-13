package org.tbyrne.composeLibrary.tools.selection2d
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.compose.concerns.Concern;
	import org.tbyrne.compose.concerns.IConcern;
	import org.tbyrne.compose.traits.AbstractTrait;
	import org.tbyrne.compose.traits.ITrait;
	import org.tbyrne.composeLibrary.controls.ISelectableCollection;
	
	public class SelectableCollection implements ISelectableCollection
	{
		
		/**
		 * @inheritDoc
		 */
		public function get collectionChanged():IAct{
			return (_collectionChanged || (_collectionChanged = new Act()));
		}
		
		public function get list():Vector.<ISelectableTrait>{
			return _list;
		}
		protected var _collectionChanged:Act;
		
		private var _list:Vector.<ISelectableTrait> = new Vector.<ISelectableTrait>();
		private var _allSelectables:Vector.<ISelectableTrait>;
		private var _updateProp:String;
		
		public function SelectableCollection(allSelectables:Vector.<ISelectableTrait>, updateProp:String){
			super();
			
			_allSelectables = allSelectables;
			_updateProp = updateProp;
		}
		
		public function addAll():void{
			if(_addMany(_allSelectables)){
				if(_collectionChanged)_collectionChanged.perform(this);
			}
		}
		public function removeAll():void{
			if(_removeMany(_list)){
				if(_collectionChanged)_collectionChanged.perform(this);
			}
		}
		
		public function add(trait:ISelectableTrait, addToSelection:Boolean):void{
			var changed:Boolean;
			if(!addToSelection && _removeMany(_list)){
				changed = true;
			}
			if(_add(trait)){
				changed = true;
			}
			if(changed && _collectionChanged)_collectionChanged.perform(this);
		}
		public function remove(trait:ISelectableTrait):void{
			if(_remove(trait,true)){
				if(_collectionChanged)_collectionChanged.perform(this);
			}
		}
		private function _add(trait:ISelectableTrait):Boolean{
			var index:int = _list.indexOf(trait);
			if(index==-1){
				trait[_updateProp] = true;
				_list.push(trait);
				return true;
			}
			return false;
		}
		public function removeNoUpdate(trait:ISelectableTrait):void{
			if(_remove(trait,false)){
				if(_collectionChanged)_collectionChanged.perform(this);
			}
		}
		private function _remove(trait:ISelectableTrait, doUpdate:Boolean):Boolean{
			var index:int = _list.indexOf(trait);
			if(index!=-1){
				if(doUpdate)trait[_updateProp] = false;
				_list.splice(index,1);
				return true;
			}
			return false;
		}
		private function _addMany(traits:Vector.<ISelectableTrait>):Boolean{
			var ret:Boolean = false;
			for each(var trait:ISelectableTrait in traits){
				if(_add(trait)){
					ret = true;
				}
			}
			return ret;
		}
		private function _removeMany(traits:Vector.<ISelectableTrait>):Boolean{
			var ret:Boolean = false;
			var i:int=0;
			var arrMatch:Boolean = traits==_list;
			while(i<traits.length){
				var trait:ISelectableTrait = traits[i];
				if(_remove(trait,true)){
					ret = true;
					if(!arrMatch)++i;
				}else{
					++i;
				}
			}
			return ret;
		}
	}
}