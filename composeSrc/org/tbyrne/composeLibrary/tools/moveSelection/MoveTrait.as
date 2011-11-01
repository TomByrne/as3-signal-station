package org.tbyrne.composeLibrary.tools.moveSelection
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.compose.traits.AbstractTrait;
	
	public class MoveTrait extends AbstractTrait implements IMoveTrait
	{
		
		/**
		 * @inheritDoc
		 */
		public function get isMovingChanged():IAct{
			return (_isMovingChanged || (_isMovingChanged = new Act()));
		}
		
		protected var _isMovingChanged:Act;
		
		public function get isMoving():Boolean{
			return _isMoving;
		}
		public function set isMoving(value:Boolean):void{
			if(_isMoving!=value){
				_isMoving = value;
				if(_isMovingChanged)_isMovingChanged.perform(this);
			}
		}
		
		private var _isMoving:Boolean;
		
		
		public function MoveTrait()
		{
			super();
		}
	}
}