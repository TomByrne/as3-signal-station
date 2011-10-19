package org.tbyrne.composeLibrary.away3d.traits
{
	import away3d.containers.ObjectContainer3D;
	
	import org.tbyrne.compose.traits.AbstractTrait;
	import org.tbyrne.composeLibrary.away3d.types.IChild3dTrait;
	
	public class Child3dTrait extends AbstractTrait implements IChild3dTrait
	{
		public function get object3d():ObjectContainer3D{
			return _child;
		}
		
		public function get child():ObjectContainer3D{
			return _child;
		}
		public function set child(value:ObjectContainer3D):void{
			if(_child!=value){
				_child = value;
			}
		}
		
		protected var _child:ObjectContainer3D;
		
		public function Child3dTrait()
		{
			super();
		}
	}
}