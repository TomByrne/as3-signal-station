package org.tbyrne.display.assets.states
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;

	public class StateDef implements IStateDef
	{
		public function get selection():int{
			return _selection;
		}
		public function set selection(value:int):void{
			if(_selection!=value){
				_selection = value;
				_stateChangeDuration = 0;
				if(_selectionChanged)_selectionChanged.perform(this);
			}
		}
		public function get options():Array{
			return _options;
		}
		public function set options(value:Array):void{
			_options = value;
		}
		public function get stateChangeDuration():Number{
			return _stateChangeDuration;
		}
		public function set stateChangeDuration(value:Number):void{
			_stateChangeDuration = value;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get selectionChanged():IAct{
			if(!_selectionChanged)_selectionChanged = new Act();
			return _selectionChanged;
		}
		
		protected var _selectionChanged:Act;
		private var _selection:int;
		private var _stateChangeDuration:Number = -1;
		private var _options:Array;
		
		public function StateDef(options:Array=null,selection:int=-1){
			this.options = options;
			this.selection = selection;
		}
		public function temporarySelect(index:int):void{
			var selWas:int = _selection;
			selection = index;
			_selection = selWas;
		}
		public function selectByString(value:String):Boolean{
			if(!value){
				selection = -1;
				return true;
			}
			for(var i:int=0; i<_options.length; i++){
				if(_options[i]==value){
					selection = i;
					return true;
				}
			}
			return false;
		}
	}
}