package org.tbyrne.composeLibrary.display3D
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.composeLibrary.controls.IRotationControls;
	
	public class RotationControls extends AbsOrientation3dTrait implements IRotationControls
	{
		/**
		 * @inheritDoc
		 */
		public function get rotationChanged():IAct{
			return rotation3dChanged;
		}
		
		
		public function set rotX(value:Number):void{
			setRotX(value);
		}
		public function set rotY(value:Number):void{
			setRotY(value);
		}
		public function set rotZ(value:Number):void{
			setRotZ(value);
		}
		
		
		public function RotationControls()
		{
		}
		
		
	}
}