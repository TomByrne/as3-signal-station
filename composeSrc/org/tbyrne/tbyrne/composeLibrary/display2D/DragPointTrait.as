package org.tbyrne.tbyrne.composeLibrary.display2D
{
	import org.tbyrne.tbyrne.compose.concerns.TraitConcern;
	import org.tbyrne.tbyrne.compose.traits.AbstractTrait;
	import org.tbyrne.tbyrne.compose.traits.ITrait;
	import org.tbyrne.tbyrne.compose.concerns.ITraitConcern;
	import org.tbyrne.tbyrne.composeLibrary.types.display2D.IPosition2dTrait;
	import org.tbyrne.tbyrne.composeLibrary.types.ui.IMouseActsTrait;
	import org.tbyrne.collections.IndexedList;
	
	public class DragPointTrait extends AbstractTrait
	{
		private var _mouseTrait:IMouseActsTrait;
		private var _points:IndexedList;
		
		public function DragPointTrait()
		{
			super();
			
			_points = new IndexedList();
			
			addConcern(new TraitConcern(true,true,IPosition2dTrait));
			addConcern(new TraitConcern(true,false,IMouseActsTrait));
		}
		
		override protected function onConcernedTraitAdded(from:ITraitConcern, trait:ITrait):void{
			var castMouse:IMouseActsTrait = trait as IMouseActsTrait;
			if(castMouse){
				CONFIG::debug{
					if(_mouseTrait){
						Log.error("Two IMouseActsTrait objects were found, unsure which to use");
					}
				}
				_mouseTrait = castMouse;
				_mouseTrait.mouseDrag.addHandler(onDrag);
			}else{
				var castPoint:IPosition2dTrait = trait as IPosition2dTrait;
				
				if(castPoint){
					_points.push(castPoint);
				}
			}
			
		}
		
		protected function onDrag(from:IMouseActsTrait, byX:Number, byY:Number):void{
			for each(var point:IPosition2dTrait in _points.list){
				point.setPosition2d(point.x + byX, point.y + byY);
			}
		}
		
		override protected function onConcernedTraitRemoved(from:ITraitConcern, trait:ITrait):void{
			if(trait==_mouseTrait){
				_mouseTrait.mouseDrag.removeHandler(onDrag);
				_mouseTrait = null;
			}else{
				_points.remove(trait);
			}
		}
	}
}