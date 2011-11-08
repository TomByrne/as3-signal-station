package org.tbyrne.composeLibrary.display2D
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.compose.traits.AbstractTrait;
	import org.tbyrne.composeLibrary.display2D.types.ILayerSortingTrait;
	
	public class LayerSortingTrait extends AbstractTrait implements ILayerSortingTrait
	{
		/**
		 * @inheritDoc
		 */
		public function get moveUp():IAct{
			return (_moveUp || (_moveUp = new Act()));
		}
		
		/**
		 * @inheritDoc
		 */
		public function get moveDown():IAct{
			return (_moveDown || (_moveDown = new Act()));
		}
		
		/**
		 * @inheritDoc
		 */
		public function get moveToTop():IAct{
			return (_moveToTop || (_moveToTop = new Act()));
		}
		
		/**
		 * @inheritDoc
		 */
		public function get moveToBottom():IAct{
			return (_moveToBottom || (_moveToBottom = new Act()));
		}
		
		/**
		 * @inheritDoc
		 */
		public function get moveAbove():IAct{
			return (_moveAbove || (_moveAbove = new Act()));
		}
		
		/**
		 * @inheritDoc
		 */
		public function get moveBelow():IAct{
			return (_moveBelow || (_moveBelow = new Act()));
		}
		
		protected var _moveBelow:Act;
		protected var _moveAbove:Act;
		protected var _moveToBottom:Act;
		protected var _moveToTop:Act;
		protected var _moveDown:Act;
		protected var _moveUp:Act;
		
		
		public function LayerSortingTrait()
		{
			super();
		}
	}
}