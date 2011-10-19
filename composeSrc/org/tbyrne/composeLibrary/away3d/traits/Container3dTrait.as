package org.tbyrne.composeLibrary.away3d.traits
{
	import org.tbyrne.compose.concerns.ITraitConcern;
	import org.tbyrne.compose.concerns.TraitConcern;
	import org.tbyrne.compose.traits.ITrait;
	import org.tbyrne.composeLibrary.away3d.types.IChild3dTrait;
	import org.tbyrne.composeLibrary.away3d.types.IContainer3dTrait;
	
	public class Container3dTrait extends Child3dTrait implements IContainer3dTrait
	{
		public function Container3dTrait(){
			super();
			
			addConcern(new TraitConcern(true,true,IChild3dTrait,[IContainer3dTrait]));
		}
		override protected function onConcernedTraitAdded(from:ITraitConcern, trait:ITrait):void{
			var castTrait:IChild3dTrait = (trait as IChild3dTrait);
			_child.addChild(castTrait.object3d);
		}
		
		override protected function onConcernedTraitRemoved(from:ITraitConcern, trait:ITrait):void{
			var castTrait:IChild3dTrait = (trait as IChild3dTrait);
			_child.removeChild(castTrait.object3d);
		}
	}
}