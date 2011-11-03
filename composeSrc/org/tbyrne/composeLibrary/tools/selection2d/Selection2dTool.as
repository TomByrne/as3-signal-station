package org.tbyrne.composeLibrary.tools.selection2d
{
	import flash.ui.Keyboard;
	
	import org.tbyrne.actInfo.IMouseActInfo;
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.compose.concerns.Concern;
	import org.tbyrne.compose.concerns.IConcern;
	import org.tbyrne.compose.traits.AbstractTrait;
	import org.tbyrne.compose.traits.ITrait;
	import org.tbyrne.composeLibrary.depth.DepthTraitCollection;
	import org.tbyrne.composeLibrary.depth.IDepthAdjudicator;
	import org.tbyrne.composeLibrary.depth.IDepthAdjudicatorTrait;
	import org.tbyrne.composeLibrary.types.display2D.IHitTestTrait;
	import org.tbyrne.composeLibrary.types.ui.IKeyActsTrait;
	import org.tbyrne.composeLibrary.types.ui.IMouseActsTrait;
	import org.tbyrne.data.dataTypes.IBooleanProvider;
	import org.tbyrne.geom.rect.IRectangleProvider;
	import org.tbyrne.geom.rect.RectangleData;
	
	public class Selection2dTool extends AbstractTrait implements ISelectorTrait
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
		
		private var _mouseActsTrait:IMouseActsTrait;
		private var _hitTesters:Vector.<IHitTestTrait> = new Vector.<IHitTestTrait>();
		
		private var _marqueeProvider:RectangleData;
		
		private var _selection:Vector.<ISelectable2dTrait> = new Vector.<ISelectable2dTrait>();
		private var _interested:Vector.<ISelectable2dTrait> = new Vector.<ISelectable2dTrait>();
		
		private var _openMarquee:Boolean;
		private var _dragging:Boolean;
		private var _isOver:ISelectable2dTrait;
		
		public function Selection2dTool()
		{
			super();
			
			_marqueeProvider = new RectangleData();
			
			addConcern(new Concern(true,true,false,ISelectable2dTrait));
			addConcern(new Concern(true,false,false,IDepthAdjudicatorTrait));
			addConcern(new Concern(true,false,false,IMouseActsTrait));
			addConcern(new Concern(true,false,false,IKeyActsTrait));
			addConcern(new Concern(true,false,false,IHitTestTrait));
		}
		override protected function onConcernedTraitAdded(from:IConcern, trait:ITrait):void{
			var mouseActsTrait:IMouseActsTrait;
			var keyActsTrait:IKeyActsTrait;
			var depthAdjudicatorTrait:IDepthAdjudicatorTrait;
			var hitTestTrait:IHitTestTrait;
			var selectableTrait:ISelectable2dTrait;
			
			if(mouseActsTrait = trait as IMouseActsTrait){
				_mouseActsTrait = mouseActsTrait;
				_mouseActsTrait.mouseClick.addHandler(onMouseClicked);
				_mouseActsTrait.mouseMoved.addHandler(onMouseMoved);
				_mouseActsTrait.mouseDragStart.addHandler(onMouseDragStart);
				_mouseActsTrait.mouseDragFinish.addHandler(onMouseDragFinish);
				
			}else if(keyActsTrait = trait as IKeyActsTrait){
				
				_ctrlBoolean = keyActsTrait.getKeyIsDown(Keyboard.CONTROL);
				_shiftBoolean = keyActsTrait.getKeyIsDown(Keyboard.SHIFT);
			}else if(depthAdjudicatorTrait = trait as IDepthAdjudicatorTrait){
				if(!depthAdjudicator){
					depthAdjudicator = depthAdjudicatorTrait.depthAdjudicator;
				}
			}else if(hitTestTrait = trait as IHitTestTrait){
				_hitTesters.push(hitTestTrait);
			}
			if(selectableTrait = (trait as ISelectable2dTrait)){
				_depthCollection.addTrait(selectableTrait);
				selectableTrait.setInterested(false);
				selectableTrait.setSelected(false);
			}
		}
		override protected function onConcernedTraitRemoved(from:IConcern, trait:ITrait):void{
			var mouseActsTrait:IMouseActsTrait;
			var keyActsTrait:IKeyActsTrait;
			var depthAdjudicatorTrait:IDepthAdjudicatorTrait;
			var hitTestTrait:IHitTestTrait;
			var selectableTrait:ISelectable2dTrait;
			
			if(mouseActsTrait = trait as IMouseActsTrait){
				_mouseActsTrait = mouseActsTrait;
				_dragging = false;
				if(_openMarquee){
					_openMarquee = false;
					_mouseActsTrait.mouseDrag.removeHandler(onMouseDrag);
				}
				
				_mouseActsTrait.mouseClick.removeHandler(onMouseClicked);
				_mouseActsTrait.mouseMoved.removeHandler(onMouseMoved);
				_mouseActsTrait.mouseDragStart.removeHandler(onMouseDragStart);
				_mouseActsTrait.mouseDragFinish.removeHandler(onMouseDragFinish);
				_mouseActsTrait = null;
				
			}else if(keyActsTrait = trait as IKeyActsTrait){
				_ctrlBoolean = null;
				_shiftBoolean = null;
			}else if(depthAdjudicatorTrait = trait as IDepthAdjudicatorTrait){
				if(depthAdjudicator == depthAdjudicatorTrait.depthAdjudicator){
					depthAdjudicator = null;
				}
			}else if(hitTestTrait = trait as IHitTestTrait){
				var index:int = _hitTesters.indexOf(hitTestTrait);
				_hitTesters.splice(index,1);
			}
			if(selectableTrait = (trait as ISelectable2dTrait)){
				_depthCollection.removeTrait(selectableTrait);
				var selected:int = _selection.indexOf(selectableTrait);
				if(selected!=-1){
					_selection.splice(selected,1);
					selectableTrait.setSelected(false);
					if(_selectionChanged)_selectionChanged.perform(this);
				}
				if(_isOver==selectableTrait){
					selectableTrait.setInterested(false);
					_isOver = null;
				}
			}
		}
		
		private function onMouseMoved(from:IMouseActsTrait, actInfo:IMouseActInfo):void
		{
			if(!_dragging){
				var retObj:Object = {};
				_depthCollection.callOnTraits(checkHit,false,[actInfo,retObj]);
				if(_isOver!=retObj.hit){
					if(_isOver){
						_isOver.setInterested(false);
					}
					_isOver = retObj.hit;
					if(_isOver){
						_isOver.setInterested(true);
					}
				}
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
			var retObj:Object = {};
			_depthCollection.callOnTraits(checkHit,false,[actInfo,retObj]);
			var hit:ISelectable2dTrait = retObj.hit;
			if(!retObj.hit){
				_openMarquee = true;
				_marqueeProvider.setRectangle(actInfo.screenX, actInfo.screenY,0,0);
				_mouseActsTrait.mouseDrag.addHandler(onMouseDrag);
			}else{
				if(_selection.indexOf(hit)!=1){
					select(hit, (_ctrlBoolean.booleanValue  || _shiftBoolean.booleanValue));
				}
			}
			_dragging = true;
		}
		
		private function onMouseDrag(from:IMouseActsTrait, actInfo:IMouseActInfo, byX:Number, byY:Number):void{
			_marqueeProvider.width += byX;
			_marqueeProvider.height += byY;
			
			_depthCollection.callOnTraits(checkInterested,false);
		}
		
		private function onMouseDragFinish(from:IMouseActsTrait, actInfo:IMouseActInfo):void{
			_dragging = false;
			if(_openMarquee){
				_openMarquee = false;
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
					if(_selectionChanged)_selectionChanged.perform(this);
				}
				_mouseActsTrait.mouseDrag.removeHandler(onMouseDrag);
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
		public function select(trait:ISelectable2dTrait, addToSelection:Boolean):void{
			var removed:Boolean;
			if(!addToSelection && _selection.length){
				removed = true;
				_depthCollection.callOnTraits(doDeselect,false,[false]);
			}
			var added:Boolean = addToCollection(_selection, trait);
			if(added || removed){
				trait.setSelected(true);
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
				collection.push(trait);
				return true;
			}
			return false
		}
		private function removeFromCollection(collection:Vector.<ISelectable2dTrait>, trait:ISelectable2dTrait):Boolean{
			var index:int = collection.indexOf(trait);
			if(index!=-1){
				collection.splice(index,1);
				return true;
			}
			return false;
		}
		
		
		
		private function checkHit(index:int, trait:ISelectable2dTrait, actInfo:IMouseActInfo, retObj:Object):Boolean{
			if(checkPoint(trait,actInfo.screenX,actInfo.screenY)){
				retObj.hit = trait;
				return true;
			}
			return false;
		}
		
		private function doClicked(index:int, trait:ISelectable2dTrait, actInfo:IMouseActInfo, doToggle:Boolean):void{
			var selected:Boolean = (_selection.indexOf(trait)!=-1);
			var changed:Boolean;
			if((!selected || doToggle) && checkPoint(trait,actInfo.screenX,actInfo.screenY)){
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
		
		
		private function checkInterested(index:int, trait:ISelectable2dTrait):void{
			var interested:Boolean = (_interested.indexOf(trait)!=-1);
			var shouldBe:Boolean = checkRectangle(trait,_marqueeProvider.x,_marqueeProvider.y,_marqueeProvider.width,_marqueeProvider.height)>_marqueeSelectionPercent;
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
		
		
		private function checkPoint(trait:ISelectable2dTrait, screenX:Number, screenY:Number):Boolean{
			for each(var hitTester:IHitTestTrait in _hitTesters){
				if(hitTester.hitTest(trait,screenX,screenY)){
					return true;
				}
			}
			return false;
		}
		private function checkRectangle(trait:ISelectable2dTrait, x:Number, y:Number, width:Number, height:Number):Number{
			// TODO Auto Generated method stub
			return 0;
		}
	}
}