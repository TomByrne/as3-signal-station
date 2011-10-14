package org.tbyrne.tbyrne.composeLibrary.draw
{
	import org.tbyrne.tbyrne.compose.concerns.TraitConcern;
	import org.tbyrne.tbyrne.compose.traits.AbstractTrait;
	import org.tbyrne.tbyrne.compose.traits.ITrait;
	import org.tbyrne.tbyrne.compose.concerns.ITraitConcern;
	import org.tbyrne.tbyrne.composeLibrary.types.draw.IFrameAwareTrait;
	import org.tbyrne.collections.IndexedList;
	
	public class FrameSizer extends AbstractTrait
	{
		private var _frameSizeTraits:IndexedList
		private var _width:Number;
		private var _height:Number;
		private var _set:Boolean;
		
		public function FrameSizer(){
			super();
			
			_frameSizeTraits = new IndexedList();
			
			addConcern(new TraitConcern(true,true,IFrameAwareTrait));
		}
		
		public function setSize(width:Number, height:Number):void{
			if(_width != width || _height != height){
				_width = width;
				_height = height;
				_set = true;
				for each(var trait:IFrameAwareTrait in _frameSizeTraits.list){
					trait.setSize(_width,_height);
				}
			}
		}
		
		override protected function onConcernedTraitAdded(from:ITraitConcern, trait:ITrait):void{
			var cast:IFrameAwareTrait = trait as IFrameAwareTrait
			_frameSizeTraits.push(cast);
			if(_set)cast.setSize(_width,_height);
		}
		override protected function onConcernedTraitRemoved(from:ITraitConcern, trait:ITrait):void{
			_frameSizeTraits.remove(trait);
		}
	}
}