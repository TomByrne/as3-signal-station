package org.tbyrne.composeLibrary.display3D
{
	import org.tbyrne.composeLibrary.display3D.types.IMatrix3dTrait;
	import org.tbyrne.composeLibrary.display3D.types.IRotation3dTrait;

	public class Rotation3dTrait extends AbsOrientation3dTrait implements IMatrix3dTrait, IRotation3dTrait
	{
		public function set rotX(value:Number):void{
			setRotX(value);
		}
		public function set rotY(value:Number):void{
			setRotY(value);
		}
		public function set rotZ(value:Number):void{
			setRotZ(value);
		}
		public function Rotation3dTrait()
		{
			super();
		}
		override protected function compileMatrix():void{
			super.compileMatrix();
		}
	}
}