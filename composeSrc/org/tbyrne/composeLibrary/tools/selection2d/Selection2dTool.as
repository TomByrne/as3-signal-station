package org.tbyrne.composeLibrary.tools.selection2d
{
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	
	import org.tbyrne.actInfo.IMouseActInfo;
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.compose.concerns.ITraitConcern;
	import org.tbyrne.compose.concerns.TraitConcern;
	import org.tbyrne.compose.traits.AbstractTrait;
	import org.tbyrne.compose.traits.ITrait;
	import org.tbyrne.composeLibrary.controls.ISelectionControls;
	import org.tbyrne.composeLibrary.depth.DepthTraitCollection;
	import org.tbyrne.composeLibrary.depth.IDepthAdjudicator;
	import org.tbyrne.composeLibrary.depth.IDepthAdjudicatorTrait;
	import org.tbyrne.composeLibrary.types.ui.IKeyActsTrait;
	import org.tbyrne.composeLibrary.types.ui.IMouseActsTrait;
	import org.tbyrne.data.core.ValueData;
	import org.tbyrne.data.dataTypes.IBooleanProvider;
	import org.tbyrne.data.dataTypes.IValueProvider;
	import org.tbyrne.display.DisplayNamespace;
	import org.tbyrne.geom.rect.IRectangleProvider;
	import org.tbyrne.geom.rect.RectangleData;
	
	public class Selection2dTool extends AbstractTrait implements ISelectionControls
	{
		
		/**
		 * @inheritDoc
		 */
		public function get selectionChanged():IAct{
			return (_selectionChanged || (_selectionChanged = new Act()));
		}
		
		protected var _selectionChanged:Act;
		
		public function get selection():Vector.<ISelectable2dTrait>{
			return _selection;
		}
		
		
		public function get marqueeSelectionPercent():Number{
			return _marqueeSelectionPercent;
		}
		public function set marqueeSelectionPercent(value:Number):void{
			_marqueeSelectionPercent = value;
		}
		
		private var _marqueeSelectionPercent:Number = 0.1;
		
		
		public function get marqueeProvider():IRectangleProvider{
			return _marqueeProvider;
		}
		
		public function get depthAdjudicator():IDepthAdjudicator{
			return _depthCollection.depthAdjudicator;
		}
		public function set depthAdjudicator(value:IDepthAdjudicator):void{
			_depthCollection.depthAdjudicator = value;
		}
		
		private var _depthCollection:DepthTraitCollection = new DepthTraitCollection();
		
		private var _ctrlBoolean:IBooleanProvider;
		private var _shiftBoolean:IBooleanProvider;
		
		private var _marqueeProvider:RectangleData;
		
		private var _selection:Vector.<ISelectable2dTrait> = new Vector.<ISelectable2dTrait>();
		private var _interested:Vector.<ISelectable2dTrait> = new Vector.<ISelectable2dTrait>();
		
		public function Selection2dTool()
		{
			super();
			
			_marqueeProvider = new RectangleData();
			
			addConcern(new TraitConcern(true,true,ISelectable2dTrait));
			addConcern(new TraitConcern(true,false,IDepthAdjudicatorTrait));
			addConcern(new TraitConcern(true,false,IMouseActsTrait));
			addConcern(new TraitConcern(true,false,IKeyActsTrait));
		}
		override protected function onConcernedTraitAdded(from:ITraitConcern, trait:ITrait):void{
			var mouseActsTrait:IMouseActsTrait;
			var keyActsTrait:IKeyActsTrait;
			var depthAdjudicatorTrait:IDepthAdjudicatorTrait;
			
			if(mouseActsTrait = trait as IMouseActsTrait){
				
				mouseActsTrait.mouseClick.addHandler(onMouseClicked);
				
				mouseActsTrait.mouseDragStart.addHandler(onMouseDragStart);
				mouseActsTrait.mouseDrag.addHandler(onMouseDrag);
				mouseActsTrait.mouseDragFinish.addHandler(onMouseDragFinish);
				
			}else if(keyActsTrait = trait as IKeyActsTrait){
				
				_ctrlBoolean = keyActsTrait.getKeyIsDown(Keyboard.CONTROL);
				_shiftBoolean = keyActsTrait.getKeyIsDown(Keyboard.SHIFT);
			}else if(depthAdjudicatorTrait = trait as IDepthAdjudicatorTrait){
				if(!depthAdjudicator){
					depthAdjudicator = depthAdjudicatorTrait.depthAdjudicator;
				}
			}else{
				_depthCollection.addTrait(trait);
			}
		}
		override protected function onConcernedTraitRemoved(from:ITraitConcern, trait:ITrait):void{
			var mouseActsTrait:IMouseActsTrait;
			var keyActsTrait:IKeyActsTrait;
			var depthAdjudicatorTrait:IDepthAdjudicatorTrait;
			
			if(mouseActsTrait = trait as IMouseActsTrait){
				
				mouseActsTrait.mouseClick.removeHandler(onMouseClicked);
				
				mouseActsTrait.mouseDragStart.removeHandler(onMouseDragStart);
				mouseActsTrait.mouseDrag.removeHandler(onMouseDrag);
				mouseActsTrait.mouseDragFinish.removeHandler(onMouseDragFinish);
				
			}else if(keyActsTrait = trait as IKeyActsTrait){
				_ctrlBoolean = null;
				_shiftBoolean = null;
			}else if(depthAdjudicatorTrait = trait as IDepthAdjudicatorTrait){
				if(depthAdjudicator == depthAdjudicatorTrait.depthAdjudicator){
					depthAdjudicator = null;
				}
			}else{
				_depthCollection.removeTrait(trait);
			}
		}
		
		private function onMouseClicked(from:IMouseActsTrait, actInfo:IMouseActInfo):void{
			if(!_ctrlBoolean.booleanValue && !_shiftBoolean.booleanValue){
				deselectAll();
				_depthCollection.callOnTraits(doClicked,false,[actInfo,false]);
			}else{
				_depthCollection.callOnTraits(doClicked,false,[actInfo,true]);
			}
		}
		
		private function onMouseDragStart(from:IMouseActsTrait, actInfo:IMouseActInfo):void{
			_marqueeProvider.setRectangle(actInfo.screenX, actInfo.screenY,0,0);
			
		}
		
		private function onMouseDrag(from:IMouseActsTrait, actInfo:IMouseActInfo, byX:Number, byY:Number):void{
			_marqueeProvider.width += byX;
			_marqueeProvider.height += byY;
			
			_depthCollection.callOnTraits(checkInterested,false);
		}
		
		private function onMouseDragFinish(from:IMouseActsTrait, actInfo:IMouseActInfo):void{
			_marqueeProvider.setRectangle(NaN,NaN,NaN,NaN);
			
			if(!_ctrlBoolean.booleanValue && !_shiftBoolean.booleanValue){
				deselectAll();
			}
			if(_interested.length){
				for each(var trait:ISelectable2dTrait in _interested){
					if(addToCollection(_selection,trait)){
						trait.setSelected(true);
					}
					trait.setInterested(false);
				}
				_interested = new Vector.<ISelectable2dTrait>();
			}
		}
		
		
		public function selectAll():void{
			if(_selection.length<_depthCollection.length){
				_depthCollection.callOnTraits(doSelect,false,[false]);
				if(_selectionChanged)_selectionChanged.perform(this);
			}
		}
		public function deselectAll():void{
			if(_selection.length){
				_depthCollection.callOnTraits(doDeselect,false,[false]);
				if(_selectionChanged)_selectionChanged.perform(this);
			}
		}
		public function select(trait:ISelectable2dTrait):void{
			var changed:Boolean = addToCollection(_selection, trait);
			if(changed){
				trait.setSelected(false);
				if(_selectionChanged)_selectionChanged.perform(this);
			}
		}
		public function deselect(trait:ISelectable2dTrait):void{
			var changed:Boolean = removeFromCollection(_selection, trait);
			if(changed){
				trait.setSelected(false);
				if(_selectionChanged)_selectionChanged.perform(this);
			}
		}
		
		
		private function addToCollection(collection:Vector.<ISelectable2dTrait>, trait:ISelectable2dTrait):Boolean{
			if(collection.indexOf(trait)==-1){
				trait.setSelected(true);
				
				collection.push(trait);
				return true;
			}
			return false
		}
		private function removeFromCollection(collection:Vector.<ISelectable2dTrait>, trait:ISelectable2dTrait):Boolean{
			var index:int = collection.indexOf(trait);
			if(index!=-1){
				trait.setSelected(false);
				collection.splice(index,1);
				return true;
			}
			return false;
		}
		
		
		
		
		
		private function doClicked(index:int, trait:ISelectable2dTrait, actInfo:IMouseActInfo, doToggle:Boolean):void{
			var selected:Boolean = (_selection.indexOf(trait)!=-1);
			var changed:Boolean;
			if((!selected || doToggle) && trait.checkPoint(actInfo.screenX,actInfo.screenY)){
				if(selected){
					changed = removeFromCollection(_selection,trait);
				}else{
					changed = addToCollection(_selection, trait);
				}
			}
			if(changed){
				trait.setSelected(!selected);
				if(_selectionChanged)selectionChanged.perform(this);
			}
		}
		
		private function doSelect(index:int, trait:ISelectable2dTrait, allowEvents:Boolean):void{
			var changed:Boolean = addToCollection(_selection, trait);
			if(changed){
				trait.setSelected(true);
				if(allowEvents && _selectionChanged)_selectionChanged.perform(this);
			}
		}
		
		private function doDeselect(index:int, trait:ISelectable2dTrait, allowEvents:Boolean):void{
			var changed:Boolean = removeFromCollection(_selection, trait);
			if(changed){
				trait.setSelected(false);
				if(allowEvents && _selectionChanged)_selectionChanged.perform(this);
			}
		}
		
		
		private function checkInterested(index:int, trait:ISelectable2dTrait, actInfo:IMouseActInfo, doToggle:Boolean):void{
			var interested:Boolean = (_interested.indexOf(trait)!=-1);
			var shouldBe:Boolean = trait.checkRectangle(_marqueeProvider.x,_marqueeProvider.y,_marqueeProvider.width,_marqueeProvider.height)>_marqueeSelectionPercent;
			if(interested){
				if(!shouldBe){
					if(removeFromCollection(_interested, trait)){
						trait.setInterested(false);
					}
				}
			}else if(shouldBe){
				if(addToCollection(_interested, trait)){
					trait.setInterested(true);
				}
			}
		}
	}
}