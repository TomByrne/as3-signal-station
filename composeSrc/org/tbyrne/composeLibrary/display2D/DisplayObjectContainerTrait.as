package org.tbyrne.composeLibrary.display2D
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	
	import org.tbyrne.compose.concerns.IConcern;
	import org.tbyrne.compose.concerns.Concern;
	import org.tbyrne.compose.traits.ITrait;
	import org.tbyrne.composeLibrary.types.display2D.IDisplayContainerTrait;
	import org.tbyrne.composeLibrary.types.display2D.IDisplayObjectTrait;
	
	public class DisplayObjectContainerTrait extends DisplayObjectTrait implements IDisplayContainerTrait
	{
		protected var _addChildren:Boolean = true;
		protected var _container:DisplayObjectContainer;
		
		public function DisplayObjectContainerTrait(displayObject:DisplayObjectContainer=null)
		{
			_container = (displayObject || new Sprite())
			
			super(_container);
			
			addConcern(new Concern(true,true,IDisplayObjectTrait,[IDisplayContainerTrait]));
		}
		override protected function onConcernedTraitAdded(from:IConcern, trait:ITrait):void{
			if(trait==this || !_addChildren)return;
			
			var castTrait:IDisplayObjectTrait = (trait as IDisplayObjectTrait);
			_container.addChild(castTrait.displayObject);
		}
		override protected function onConcernedTraitRemoved(from:IConcern, trait:ITrait):void{
			if(trait==this || !_addChildren)return;
			
			var castTrait:IDisplayObjectTrait = (trait as IDisplayObjectTrait);
			_container.removeChild(castTrait.displayObject);
		}
			
	}
}