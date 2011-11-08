package org.tbyrne.composeLibrary.tools.snapping
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.compose.concerns.Concern;
	import org.tbyrne.compose.concerns.IConcern;
	import org.tbyrne.compose.traits.AbstractTrait;
	import org.tbyrne.compose.traits.ITrait;
	import org.tbyrne.composeLibrary.display3D.types.IPosition3dTrait;
	
	public class SnappableTrait extends AbstractTrait implements ISnappableTrait
	{
		
		/**
		 * @inheritDoc
		 */
		public function get position3dChanged():IAct{
			return (_position3dChanged || (_position3dChanged = new Act()));
		}
		
		protected var _position3dChanged:Act;
		
		
		public function get nestedPosition3d():IPosition3dTrait{
			return _explicitPosition3d;
		}
		public function set nestedPosition3d(value:IPosition3dTrait):void{
			if(_explicitPosition3d!=value){
				_explicitPosition3d = value;
				assessPosition();
			}
		}
		
		public function get snappingGroup():String{
			return _snappingGroup;
		}
		public function set snappingGroup(value:String):void{
			_snappingGroup = value;
		}
		
		public function get x3d():Number{
			return _usedPosition3d?_usedPosition3d.x3d:NaN;
		}
		public function get y3d():Number{
			return _usedPosition3d?_usedPosition3d.y3d:NaN;
		}
		public function get z3d():Number{
			return _usedPosition3d?_usedPosition3d.z3d:NaN;
		}
		
		private var _snappingGroup:String;
		private var _explicitPosition3d:IPosition3dTrait;
		private var _caughtPosition3d:IPosition3dTrait;
		private var _usedPosition3d:IPosition3dTrait;
		
		
		public function SnappableTrait(){
			super();
			
			addConcern(new Concern(true,false,false,IPosition3dTrait));
		}
		
		protected function onConcernedTraitAdded(from:IConcern, trait:ITrait):void{
			_caughtPosition3d = trait as IPosition3dTrait;
			assessPosition();
		}
		protected function onConcernedTraitRemoved(from:IConcern, trait:ITrait):void{
			_caughtPosition3d = null;
			assessPosition();
		}
		
		public function setPosition3d(x:Number, y:Number, z:Number):void{
			_usedPosition3d.setPosition3d(x,y,z);
		}
		
		private function assessPosition():void{
			var pos:IPosition3dTrait = (_explicitPosition3d || _caughtPosition3d);
			
			if(_usedPosition3d!=pos){
				if(_usedPosition3d){
					_usedPosition3d.position3dChanged.removeHandler(onPosChanged);
				}
				
				_usedPosition3d = pos;
				
				if(_usedPosition3d){
					_usedPosition3d.position3dChanged.addHandler(onPosChanged);
				}
				if(_position3dChanged)_position3dChanged.perform(this);
			}
		}
		
		private function onPosChanged(from:IPosition3dTrait):void{
			if(_position3dChanged)_position3dChanged.perform(this);
		}
	}
}