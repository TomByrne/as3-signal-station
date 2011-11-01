package org.tbyrne.composeLibrary.away3d.traits
{
	import away3d.containers.ObjectContainer3D;
	
	import org.tbyrne.compose.concerns.IConcern;
	import org.tbyrne.compose.concerns.Concern;
	import org.tbyrne.compose.traits.ITrait;
	import org.tbyrne.composeLibrary.away3d.types.IChild3dTrait;
	import org.tbyrne.composeLibrary.away3d.types.IContainer3dTrait;
	
	public class Container3dTrait extends Child3dTrait implements IContainer3dTrait
	{
		public function Container3dTrait(child:ObjectContainer3D=null){
			super(child);
			
			addConcern(new Concern(true,true,false,IChild3dTrait,[IContainer3dTrait]));
		}
		override protected function onConcernedTraitAdded(from:IConcern, trait:ITrait):void{
			var castTrait:IChild3dTrait = (trait as IChild3dTrait);
			if(castTrait==this)return;
			
			_child.addChild(castTrait.object3d);
		}
		
		override protected function onConcernedTraitRemoved(from:IConcern, trait:ITrait):void{
			var castTrait:IChild3dTrait = (trait as IChild3dTrait);
			if(castTrait==this)return;
			
			if(_child.contains(castTrait.object3d))_child.removeChild(castTrait.object3d);
		}
	}
}