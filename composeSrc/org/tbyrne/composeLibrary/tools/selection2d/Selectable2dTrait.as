package org.tbyrne.composeLibrary.tools.selection2d
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.compose.traits.AbstractTrait;
	
	public class Selectable2dTrait extends AbstractTrait implements ISelectableTrait
	{
		
		public function get selected():Boolean{
			return _selected;
		}
		public function set selected(value:Boolean):void{
			if(_selected!=value){
				_selected = value;
				if(_selectedChanged)_selectedChanged.perform(this);
			}
		}
		/**
		 * @inheritDoc
		 */
		public function get selectedChanged():IAct{
			return (_selectedChanged || (_selectedChanged = new Act()));
		}
		
		
		
		public function get interested():Boolean{
			return _interested;
		}
		public function set interested(value:Boolean):void{
			if(_interested!=value){
				_interested = value;
				if(_interestedChanged)_interestedChanged.perform(this);
			}
		}
		/**
		 * @inheritDoc
		 */
		public function get interestedChanged():IAct{
			return (_interestedChanged || (_interestedChanged = new Act()));
		}
		
		protected var _interestedChanged:Act;
		protected var _interested:Boolean;
		
		protected var _selectedChanged:Act;
		protected var _selected:Boolean;
		
		
		public function Selectable2dTrait(selected:Boolean=false, interested:Boolean=false)
		{
			super();
			this.selected = selected;
			this.interested = interested;
		}
	}
}