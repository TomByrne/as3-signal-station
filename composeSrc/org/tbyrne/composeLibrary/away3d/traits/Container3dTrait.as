package org.tbyrne.composeLibrary.away3d.traits
{
	import away3d.containers.ObjectContainer3D;
	
	import org.tbyrne.binding.Binder;
	import org.tbyrne.compose.concerns.Concern;
	import org.tbyrne.compose.concerns.IConcern;
	import org.tbyrne.compose.traits.ITrait;
	import org.tbyrne.composeLibrary.away3d.types.IChild3dTrait;
	import org.tbyrne.composeLibrary.away3d.types.IContainer3dTrait;
	import org.tbyrne.composeLibrary.display3D.types.IPosition3dTrait;
	
	public class Container3dTrait extends Child3dTrait implements IContainer3dTrait
	{
		
		public function get positionTrait():IPosition3dTrait{
			return _positionTrait;
		}
		public function set positionTrait(value:IPosition3dTrait):void{
			if(_positionTrait!=value){
				if(_positionTrait){
					_positionTrait.position3dChanged.removeHandler(onPos3DChanged);
				}
				_positionTrait = value;
				if(_positionTrait){
					_positionTrait.position3dChanged.addHandler(onPos3DChanged);
					setPosition();
				}
			}
		}
		override public function set child(value:ObjectContainer3D):void{
			super.child = value;
			if(_positionTrait)setPosition();
		}
		
		private var _positionTrait:IPosition3dTrait;
		
		
		
		public function Container3dTrait(child:ObjectContainer3D=null){
			super(child);
			
			addConcern(new Concern(true,true,false,IChild3dTrait,[IContainer3dTrait]));
			addConcern(new Concern(true,false,false,IPosition3dTrait));
		}
		override protected function onConcernedTraitAdded(from:IConcern, trait:ITrait):void{
			var childTrait:IChild3dTrait = (trait as IChild3dTrait);
			var posTrait:IPosition3dTrait = (trait as IPosition3dTrait);
			
			if(childTrait){
				if(childTrait==this)return;
				
				_child.addChild(childTrait.object3d);
			}
			if(posTrait){
				this.positionTrait = posTrait;
			}
		}
		
		override protected function onConcernedTraitRemoved(from:IConcern, trait:ITrait):void{
			var childTrait:IChild3dTrait = (trait as IChild3dTrait);
			var posTrait:IPosition3dTrait = (trait as IPosition3dTrait);
			
			if(childTrait){
				if(childTrait==this)return;
				
				if(_child.contains(childTrait.object3d))_child.removeChild(childTrait.object3d);
			}
			if(posTrait){
				this.positionTrait = null;
			}
		}
		
		
		
		private function onPos3DChanged(from:IPosition3dTrait):void
		{
			setPosition();
		}
		
		private function setPosition():void{
			if(_child){
				_child.x = _positionTrait.x3d;
				_child.y = _positionTrait.y3d;
				_child.z = _positionTrait.z3d;
			}
		}
	}
}