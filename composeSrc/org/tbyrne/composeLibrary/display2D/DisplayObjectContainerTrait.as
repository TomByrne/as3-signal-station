package org.tbyrne.composeLibrary.display2D
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	
	import org.tbyrne.compose.concerns.Concern;
	import org.tbyrne.compose.concerns.IConcern;
	import org.tbyrne.compose.traits.ITrait;
	import org.tbyrne.composeLibrary.display2D.types.IDisplayContainerTrait;
	import org.tbyrne.composeLibrary.display2D.types.IDisplayObjectTrait;
	
	public class DisplayObjectContainerTrait extends DisplayObjectTrait implements IDisplayContainerTrait
	{
		override public function set displayObject(value:DisplayObject):void{
			super.displayObject = value;
			_container = (value as DisplayObjectContainer);
		}
		
		protected var _addChildren:Boolean = true;
		protected var _container:DisplayObjectContainer;
		
		public function DisplayObjectContainerTrait(displayObject:DisplayObject=null)
		{
			super(displayObject);
			
			addConcern(new Concern(true,true,false,IDisplayObjectTrait,[IDisplayContainerTrait]));
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