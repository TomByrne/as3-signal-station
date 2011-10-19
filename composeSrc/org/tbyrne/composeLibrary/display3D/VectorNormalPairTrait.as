package org.tbyrne.composeLibrary.display3D
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.compose.traits.AbstractTrait;
	import org.tbyrne.composeLibrary.types.display3D.IVectorNormalPairTrait;
	
	public class VectorNormalPairTrait extends AbstractTrait implements IVectorNormalPairTrait
	{
		
		/**
		 * @inheritDoc
		 */
		public function get vectorNormalChanged():IAct{
			return (_vectorNormalChanged || (_vectorNormalChanged = new Act()));
		}
		
		protected var _vectorNormalChanged:Act;
		
		
		public function get vectorX():Number{
			return _vectorX;
		}
		public function set vectorX(value:Number):void{
			if(_vectorX!=value){
				_vectorX = value;
				if(_vectorNormalChanged)_vectorNormalChanged.perform(this);
			}
		}
		
		public function get vectorY():Number{
			return _vectorY;
		}
		public function set vectorY(value:Number):void{
			if(_vectorY!=value){
				_vectorY = value;
				if(_vectorNormalChanged)_vectorNormalChanged.perform(this);
			}
		}
		
		public function get vectorZ():Number{
			return _vectorZ;
		}
		public function set vectorZ(value:Number):void{
			if(_vectorZ!=value){
				_vectorZ = value;
				if(_vectorNormalChanged)_vectorNormalChanged.perform(this);
			}
		}
		
		public function get normalX():Number{
			return _normalX;
		}
		public function set normalX(value:Number):void{
			if(_normalX!=value){
				_normalX = value;
				if(_vectorNormalChanged)_vectorNormalChanged.perform(this);
			}
		}
		
		public function get normalY():Number{
			return _normalY;
		}
		public function set normalY(value:Number):void{
			if(_normalY!=value){
				_normalY = value;
				if(_vectorNormalChanged)_vectorNormalChanged.perform(this);
			}
		}
		
		public function get normalZ():Number{
			return _normalZ;
		}
		public function set normalZ(value:Number):void{
			if(_normalZ!=value){
				_normalZ = value;
				if(_vectorNormalChanged)_vectorNormalChanged.perform(this);
			}
		}
		
		private var _normalZ:Number;
		private var _normalY:Number;
		private var _normalX:Number;
		
		private var _vectorZ:Number;
		private var _vectorY:Number;
		private var _vectorX:Number;
		
		
		public function VectorNormalPairTrait(){
			super();
		}
		
		public function setVectorAndNormal(x:Number, y:Number, z:Number, nX:Number, nY:Number, nZ:Number):void{
			if(_setVector(x,y,z) || _setNormal(nX,nY,nZ)){
				if(_vectorNormalChanged)_vectorNormalChanged.perform(this);
			}
		}
		public function setVector(x:Number, y:Number, z:Number):void{
			if(_setVector(x,y,z)){
				if(_vectorNormalChanged)_vectorNormalChanged.perform(this);
			}
		}
		private function _setVector(x:Number, y:Number, z:Number):Boolean{
			if(x!=_vectorX || y!=_vectorY || z!=_vectorZ){
				_vectorX = x;
				_vectorY = y;
				_vectorZ = z;
				return true;
			}else{
				return false;
			}
		}
		public function setNormal(x:Number, y:Number, z:Number):void{
			if(_setNormal(x,y,z)){
				if(_vectorNormalChanged)_vectorNormalChanged.perform(this);
			}
		}
		private function _setNormal(x:Number, y:Number, z:Number):Boolean{
			if(x!=_normalX || y!=_normalY || z!=_normalZ){
				_normalX = x;
				_normalY = y;
				_normalZ = z;
				return true;
			}else{
				return false;
			}
		}
	}
}